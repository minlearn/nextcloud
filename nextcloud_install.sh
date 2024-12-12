###############

echo "Installing Dependencies"
apt-get install -y curl
apt-get install -y sudo
apt-get install -y mc
echo "Installed Dependencies"

NEXTCLOUD_DIR=/var/www/nextcloud

# Install Apache, PHP, and necessary PHP extensions
echo "Installing Apache and PHP..."
sudo apt install apache2 libapache2-mod-php php-gd php-json php-sqlite3 php-curl php-mbstring \
                 php-intl php-imagick php-xml php-zip -y

# Enable Apache mods
sudo a2enmod rewrite headers env dir mime



# Install Nextcloud
echo "Installing Nextcloud..."
sudo mkdir -p ${NEXTCLOUD_DIR}
cd ${NEXTCLOUD_DIR}/..
sudo wget https://download.nextcloud.com/server/releases/latest.tar.bz2
sudo tar -xjf latest.tar.bz2 -C ${NEXTCLOUD_DIR} --strip-components=1
sudo rm latest.tar.bz2
sudo chown -R www-data:www-data ${NEXTCLOUD_DIR}

# Configure Apache to serve Nextcloud
echo "Configuring Apache..."
NEXTCLOUD_CONF="/etc/apache2/sites-available/nextcloud.conf"
echo "<VirtualHost *:80>
    ServerName localhost:80
    DocumentRoot ${NEXTCLOUD_DIR}
    <Directory ${NEXTCLOUD_DIR}/>
        Require all granted
        AllowOverride All
        Options FollowSymLinks MultiViews

        <IfModule mod_dav.c>
            Dav off
        </IfModule>
    </Directory>
</VirtualHost>" | sudo tee $NEXTCLOUD_CONF

sudo a2ensite nextcloud.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2

echo "Nextcloud installation completed successfully!"
echo "You can access Nextcloud at: http://${DOMAIN_OR_IP}/"

echo "Cleaning up"
apt-get -y autoremove
apt-get -y autoclean
echo "Cleaned"

##############