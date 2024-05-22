#!/bin/bash

# ASCII art with the name "Tharana Hansaja"
cat << "EOF"

________                 .__  __  .__      __________         __        ___.                      .___.__               
\______ \ _____    _____ |__|/  |_|  |__   \______   \_____ _/  |______ \_ |__ _____    ____    __| _/|__| ____   ____  
 |    |  \\__  \  /     \|  \   __\  |  \   |     ___/\__  \\   __\__  \ | __ \\__  \  /    \  / __ | |  |/ ___\_/ __ \ 
 |    `   \/ __ \|  Y Y  \  ||  | |   Y  \  |    |     / __ \|  |  / __ \| \_\ \/ __ \|   |  \/ /_/ | |  / /_/  >  ___/ 
/_______  (____  /__|_|  /__||__| |___|  /  |____|    (____  /__| (____  /___  (____  /___|  /\____ | |__\___  / \___  >
        \/     \/      \/              \/                  \/          \/    \/     \/     \/      \/   /_____/      \/
                                                                                          
EOF


# Update package lists
sudo apt update

# Install Apache
sudo apt install apache2 -y

# Disable default virtual host configuration
sudo a2dissite 000-default.conf
sudo systemctl reload apache2

# Install MySQL and set root password
sudo apt install mysql-server -y
sudo mysql_secure_installation

# Install PHP and required modules
sudo apt install php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y

# Download and extract WordPress
sudo apt install wget -y
sudo wget -c http://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo mv wordpress /var/www/html/

# Set proper permissions
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# Create a virtual host configuration file
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf
sudo sed -i 's#/var/www/html#/var/www/html/wordpress#g' /etc/apache2/sites-available/wordpress.conf
sudo a2ensite wordpress.conf
sudo systemctl reload apache2

# Create MySQL database and user for WordPress
read -p "Enter WordPress database name: " wp_db
read -p "Enter WordPress database user: " wp_user
read -sp "Enter WordPress database password: " wp_password
echo

sudo mysql -u root -p <<MYSQL_SCRIPT
CREATE DATABASE $wp_db;
CREATE USER '$wp_user'@'localhost' IDENTIFIED BY '$wp_password';
GRANT ALL PRIVILEGES ON $wp_db.* TO '$wp_user'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Configure WordPress wp-config.php file
sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sudo sed -i "s/database_name_here/$wp_db/g" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/username_here/$wp_user/g" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/password_here/$wp_password/g" /var/www/html/wordpress/wp-config.php

# Install Certbot for Let's Encrypt SSL
sudo apt install certbot python3-certbot-apache -y

# Request SSL certificate
sudo certbot --apache

# Cleanup
sudo rm latest.tar.gz

echo "WordPress installation complete."
