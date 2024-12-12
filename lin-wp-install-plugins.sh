#!/bin/bash

# Clear the screen for better readability
clear

# Ustawienie zmiennych HTTP_HOST i SERVER_ADDR, aby zapobiec błędom, gdy są one wymagane przez wtyczki
export HTTP_HOST="localhost"
export SERVER_ADDR="127.0.0.1"

# Ustawienie raportowania błędów PHP na ignorowanie ostrzeżeń
export WP_CLI_PHP_ARGS="-d error_reporting=E_ERROR"

# Plik konfiguracyjny
CONFIG_FILE="lin-wp-install-plugins-config.txt"

# Sprawdź, czy plik konfiguracyjny istnieje
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Plik konfiguracyjny $CONFIG_FILE nie istnieje. Upewnij się, że plik istnieje i jest prawidłowy."
    exit 1
fi

# Zmienne
WP_PATH=""
DIVI_ZIP_PATH=""
MONARCH_ZIP_PATH=""
BLOOM_ZIP_PATH=""
STRIPE_ZIP_PATH=""
PLUGINS=()
TO_UNINSTALL=()

# Wczytaj ścieżkę do katalogu WordPress oraz pliki ZIP z pliku konfiguracyjnego
SECTION=""
while IFS= read -r line || [ -n "$line" ]; do
    [[ $line = \#* ]] || [[ -z "$line" ]] && continue

    if [[ $line == WP_PATH=* ]]; then
        WP_PATH="${line#WP_PATH=}"
    elif [[ $line == DIVI_ZIP_PATH=* ]]; then
        DIVI_ZIP_PATH="${line#DIVI_ZIP_PATH=}"
    elif [[ $line == MONARCH_ZIP_PATH=* ]]; then
        MONARCH_ZIP_PATH="${line#MONARCH_ZIP_PATH=}"
    elif [[ $line == BLOOM_ZIP_PATH=* ]]; then
        BLOOM_ZIP_PATH="${line#BLOOM_ZIP_PATH=}"
    elif [[ $line == STRIPE_ZIP_PATH=* ]]; then
        STRIPE_ZIP_PATH="${line#STRIPE_ZIP_PATH=}"
    elif [[ $line == to-uninstall ]]; then
        SECTION="TO_UNINSTALL"
    else
        if [[ "$SECTION" == "TO_UNINSTALL" ]]; then
            TO_UNINSTALL+=("$line")
        else
            PLUGINS+=("$line")
        fi
    fi
done < "$CONFIG_FILE"

# Zmień katalog na katalog WordPressa
cd "$WP_PATH" || exit

# Sprawdź, czy wp-cli jest zainstalowane
if ! command -v wp &> /dev/null; then
    echo "wp-cli nie jest zainstalowane. Proszę zainstalować wp-cli, aby kontynuować."
    exit 1
fi

# Sprawdź, czy są dostępne aktualizacje wtyczek i je zaktualizuj
echo "Sprawdzanie aktualizacji wtyczek..."
wp plugin update --all

# Sprawdź, czy folder motywu Divi istnieje przed próbą instalacji
if [ -d "$WP_PATH/wp-content/themes/Divi" ]; then
    echo "Folder motywu Divi istnieje. Motyw prawdopodobnie jest już zainstalowany."
else
    if [ -n "$DIVI_ZIP_PATH" ]; then
        if [ -f "$DIVI_ZIP_PATH" ]; then
            echo "Instalacja motywu Divi..."
            wp theme install "$DIVI_ZIP_PATH" --activate
        else
            echo "Plik $DIVI_ZIP_PATH nie został znaleziony."
        fi
    fi
fi

# Sprawdź i zaktualizuj wtyczkę Monarch, jeśli jest już zainstalowana
if wp plugin is-installed monarch; then
    echo "Wtyczka Monarch jest zainstalowana. Sprawdzanie aktualizacji..."
    wp plugin update monarch
else
    if [ -n "$MONARCH_ZIP_PATH" ]; then
        if [ -f "$MONARCH_ZIP_PATH" ]; then
            echo "Instalacja wtyczki Monarch..."
            wp plugin install "$MONARCH_ZIP_PATH" --activate
        else
            echo "Plik $MONARCH_ZIP_PATH nie został znaleziony."
        fi
    fi
fi

# Sprawdź i zaktualizuj wtyczkę Bloom, jeśli jest już zainstalowana
if wp plugin is-installed bloom; then
    echo "Wtyczka Bloom jest zainstalowana. Sprawdzanie aktualizacji..."
    wp plugin update bloom
else
    if [ -n "$BLOOM_ZIP_PATH" ]; then
        if [ -f "$BLOOM_ZIP_PATH" ]; then
            echo "Instalacja wtyczki Bloom..."
            wp plugin install "$BLOOM_ZIP_PATH" --activate
        else
            echo "Plik $BLOOM_ZIP_PATH nie został znaleziony."
        fi
    fi
fi

# Instalacja wtyczki Stripe Payments
if wp plugin is-installed stripe-payments; then
    echo "Wtyczka Stripe Payments jest zainstalowana. Sprawdzanie aktualizacji..."
    wp plugin update stripe-payments
else
    if [ -n "$STRIPE_ZIP_PATH" ]; then
        if [ -f "$STRIPE_ZIP_PATH" ]; then
            echo "Instalacja wtyczki Stripe Payments..."
            wp plugin install "$STRIPE_ZIP_PATH" --activate
        else
            echo "Plik $STRIPE_ZIP_PATH nie został znaleziony."
        fi
    fi
fi

# Instalacja i aktualizacja wtyczek z repozytorium WordPress
echo "Instalacja lub aktualizacja wtyczek z pliku konfiguracyjnego..."
for plugin in "${PLUGINS[@]}"; do
    # Sprawdź, czy WP Rocket jest wymagane i zastąp je alternatywą
    if [ "$plugin" == "wp-rocket" ]; then
        echo "WP Rocket wymaga ręcznej instalacji. Zastępowanie wtyczką Cache Enabler..."
        plugin="cache-enabler"
    fi

    if wp plugin is-installed "$plugin"; then
        echo "$plugin jest już zainstalowana, sprawdzam aktualizacje..."
        wp plugin update "$plugin"
    else
        echo "Instalacja wtyczki: $plugin..."
        if wp plugin install "$plugin" --activate; then
            echo "$plugin zainstalowana i aktywowana poprawnie."
        else
            echo "Wystąpił błąd podczas instalacji $plugin. Cofnięcie instalacji..."
            wp plugin delete "$plugin"
        fi
    fi
done

# Ręczna aktywacja zainstalowanych wtyczek
echo "Aktywacja wszystkich zainstalowanych wtyczek..."
for plugin in "${PLUGINS[@]}"; do
    if wp plugin is-installed "$plugin"; then
        echo "Aktywacja wtyczki: $plugin..."
        wp plugin activate "$plugin"
    fi
done

# Odinstalowanie wtyczek z listy do usunięcia
echo "Odinstalowywanie wybranych wtyczek..."
for plugin in "${TO_UNINSTALL[@]}"; do
    if wp plugin is-installed "$plugin"; then
        echo "Odinstalowywanie wtyczki: $plugin..."
        wp plugin deactivate "$plugin"
        wp plugin delete "$plugin"
    else
        echo "$plugin nie jest zainstalowana, pomijam..."
    fi
done

echo "Wszystkie wtyczki oraz motyw Divi zostały pomyślnie zainstalowane, zaktualizowane lub odinstalowane."
