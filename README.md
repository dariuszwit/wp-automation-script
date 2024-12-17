## Support Me
If you find this script useful, you can support me here:
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-donate-yellow)](https://buymeacoffee.com/dariuszwit)

# WordPress Installation and Configuration Script

This script automates the process of installing WordPress, adding themes, managing plugins, and creating multiple administrator users. It leverages WP-CLI for interacting with WordPress.

---

## **Features**
1. **WordPress Installation**:
   - Downloads WordPress core if not installed.
   - Generates `wp-config.php` with database credentials.

2. **Theme Installation**:
   - Installs and activates the **Divi** theme (`divi.zip`) from the script directory.

3. **Plugin Management**:
   - Installs and updates plugins listed in a provided configuration file.
   - Uninstalls plugins from a provided list.

4. **User Management**:
   - Creates multiple administrator users with credentials from the configuration file.

---

## **Requirements**
1. **WP-CLI**: The script automatically downloads WP-CLI if it's not present.
2. **PHP**: Ensure PHP is installed and available from the command line.
3. **Database Access**: MySQL credentials for creating a connection.
4. **Files**:
   - `lin-wp-install-plugins-config.txt`: Configuration file.
   - `lin-wp-plugins-list.txt`: List of plugins to install.
   - `lin-wp-plugins-to-uninstall.txt`: List of plugins to remove.
   - `divi.zip`: Theme file located in the script directory.

---

## **Configuration File**
Create a file named `lin-wp-install-plugins-config.txt` with the following structure:

```txt
WP_PATH=/path/to/wordpress
DB_NAME=your_db_name
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_HOST=localhost
PLUGINS_FILE=lin-wp-plugins-list.txt
TO_UNINSTALL_FILE=lin-wp-plugins-to-uninstall.txt
WP_ADMINS=admin1:password1:email1@example.com,admin2:password2:email2@example.com
```

- **WP_PATH**: The directory where WordPress will be installed.
- **DB_NAME, DB_USER, DB_PASSWORD, DB_HOST**: MySQL credentials.
- **PLUGINS_FILE**: File containing a list of plugins to install.
- **TO_UNINSTALL_FILE**: File containing a list of plugins to uninstall.
- **WP_ADMINS**: Comma-separated list of administrators with the format `username:password:email`.

---

## **Usage**
1. Place the script in the desired directory.
2. Place `divi.zip`, `lin-wp-install-plugins-config.txt`, `lin-wp-plugins-list.txt`, and `lin-wp-plugins-to-uninstall.txt` in the same directory.
3. Make the script executable:
   ```bash
   chmod +x lin-wp-install-plugins.sh
   ```
4. Run the script:
   ```bash
   ./lin-wp-install-plugins.sh
   ```

---

## **Files**
- `lin-wp-install-plugins.sh`: Main script.
- `lin-wp-install-plugins-config.txt`: Configuration file.
- `lin-wp-plugins-list.txt`: Plugins to install.
- `lin-wp-plugins-to-uninstall.txt`: Plugins to remove.
- `divi.zip`: Divi theme.

---

## **Example Plugin Files**
### **lin-wp-plugins-list.txt**
```txt
wordpress-seo # SEO plugin
updraftplus # Backup plugin
wordfence # Security plugin
```

### **lin-wp-plugins-to-uninstall.txt**
```txt
hello-dolly
akismet
```

---

## License
This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.



## Support Me
If you find this script useful, you can support me here:
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-donate-yellow)](https://buymeacoffee.com/dariuszwit)