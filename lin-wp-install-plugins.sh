#!/bin/bash

# Clear the screen for better readability
clear

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # Absolute path to the script directory
CONFIG_FILE="${SCRIPT_DIR}/lin-wp-install-plugins-config.txt"
WP_CLI="php ${SCRIPT_DIR}/wp-cli.phar"      # Full path to wp-cli.phar
DIVI_ZIP="${SCRIPT_DIR}/divi.zip"           # Path to divi.zip in the script directory

# Function to download WP-CLI if missing
download_wp_cli() {
    echo "Downloading WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    if [ $? -ne 0 ]; then
        echo "Failed to download WP-CLI. Exiting."
        exit 1
    fi
    chmod +x wp-cli.phar
    echo "WP-CLI has been successfully downloaded and made executable."
}

# Check if the configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "The configuration file $CONFIG_FILE does not exist."
    exit 1
fi

# Load configuration variables
WP_PATH=""
DB_NAME=""
DB_USER=""
DB_PASSWORD=""
DB_HOST=""
WP_ADMINS=""
PLUGINS_FILE=""
TO_UNINSTALL_FILE=""

while IFS= read -r line || [ -n "$line" ]; do
    [[ $line = \#* ]] || [[ -z "$line" ]] && continue
    [[ $line == WP_PATH=* ]] && WP_PATH="${line#WP_PATH=}"
    [[ $line == DB_NAME=* ]] && DB_NAME="${line#DB_NAME=}"
    [[ $line == DB_USER=* ]] && DB_USER="${line#DB_USER=}"
    [[ $line == DB_PASSWORD=* ]] && DB_PASSWORD="${line#DB_PASSWORD=}"
    [[ $line == DB_HOST=* ]] && DB_HOST="${line#DB_HOST=}"
    [[ $line == WP_ADMINS=* ]] && WP_ADMINS="${line#WP_ADMINS=}"
    [[ $line == PLUGINS_FILE=* ]] && PLUGINS_FILE="${line#PLUGINS_FILE=}"
    [[ $line == TO_UNINSTALL_FILE=* ]] && TO_UNINSTALL_FILE="${line#TO_UNINSTALL_FILE=}"
done < "$CONFIG_FILE"

# Check and download WP-CLI if it doesn't exist
if [ ! -f "${SCRIPT_DIR}/wp-cli.phar" ]; then
    cd "$SCRIPT_DIR" || exit
    download_wp_cli
fi

# Verify WP-CLI functionality
$WP_CLI --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "WP-CLI is not functional. Exiting."
    exit 1
fi

# Check and create WP_PATH if it doesn't exist
if [ ! -d "$WP_PATH" ]; then
    echo "The directory $WP_PATH does not exist. Creating it now..."
    mkdir -p "$WP_PATH"
    if [ $? -eq 0 ]; then
        echo "Directory $WP_PATH has been created successfully."
    else
        echo "Failed to create directory $WP_PATH. Exiting."
        exit 1
    fi
fi

# Navigate to the WordPress directory
cd "$WP_PATH" || { echo "Cannot navigate to directory $WP_PATH"; exit 1; }

# Test database connection
echo "Testing database connection..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "USE $DB_NAME;" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Error: Unable to connect to the database. Verify your database credentials."
    exit 1
fi
echo "Database connection successful."

# Download and install WordPress
if ! $WP_CLI core is-installed --allow-root; then
    echo "WordPress is not installed. Downloading and installing WordPress..."
    $WP_CLI core download --allow-root
    $WP_CLI config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASSWORD" --dbhost="$DB_HOST" --allow-root
    $WP_CLI core install --url="localhost" --title="New Site" --admin_user="admin" --admin_password="admin" --admin_email="admin@example.com" --allow-root
else
    echo "WordPress is already installed."
fi

# Install Divi theme
if [ -f "$DIVI_ZIP" ]; then
    echo "Installing Divi theme from $DIVI_ZIP..."
    $WP_CLI theme install "$DIVI_ZIP" --activate --allow-root
else
    echo "Error: divi.zip not found in script directory."
fi

# Create additional admin users
IFS=',' read -ra ADMINS <<< "$WP_ADMINS"
for admin in "${ADMINS[@]}"; do
    IFS=':' read -r username password email <<< "$admin"
    if $WP_CLI user get "$username" --allow-root > /dev/null 2>&1; then
        echo "User '$username' already exists. Skipping."
    else
        echo "Creating admin user: $username..."
        $WP_CLI user create "$username" "$email" --role=administrator --user_pass="$password" --allow-root
        echo "Admin user '$username' created successfully."
    fi
done

# Install plugins from the plugins list
if [ -f "${SCRIPT_DIR}/$PLUGINS_FILE" ]; then
    echo "Installing plugins from $PLUGINS_FILE..."
    while IFS= read -r line || [ -n "$line" ]; do
        [[ $line = \#* ]] || [[ -z "$line" ]] && continue
        plugin=$(echo "$line" | awk '{print $1}')
        if $WP_CLI plugin is-installed "$plugin" --allow-root; then
            $WP_CLI plugin update "$plugin" --allow-root
        else
            $WP_CLI plugin install "$plugin" --activate --allow-root
        fi
    done < "${SCRIPT_DIR}/$PLUGINS_FILE"
else
    echo "Error: Plugins file $PLUGINS_FILE not found."
fi

echo "All operations completed successfully."
