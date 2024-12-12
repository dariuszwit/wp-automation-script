# WordPress Plugin & Theme Installer

Automated script for managing WordPress plugin and theme installations, updates, and removals. Configurable through a single text file, designed for streamlined setup of WordPress environments.

## Features
- Install and activate plugins/themes from local ZIP files.
- Update existing plugins and themes.
- Remove unnecessary plugins automatically.
- Manage settings via a single configuration file.

## Prerequisites
- WordPress CLI (`wp-cli`) installed and accessible in the terminal.
- Bash environment (e.g., Linux, macOS, or WSL on Windows).

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/<YourUsername>/wp-plugin-theme-installer.git
   ```

2. Edit the `lin-wp-install-plugins-config.txt` file to fit your WordPress environment.

3. Place required ZIP files (e.g., `Divi.zip`, `monarch.zip`) in the script directory.

## Usage
Run the script:
```bash
bash lin-wp-install-plugins.sh
```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
