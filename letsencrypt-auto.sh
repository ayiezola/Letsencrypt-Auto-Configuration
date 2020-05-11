#!/bin/sh

echo "###################################"
echo  "  Script by Bob/Noyes/Ayiezola    "
echo "Letsencrypt Auto Configuration v1.0"
echo "            #StayHome              "
echo "###################################"
echo " "
echo "Your sites domain name ? (ex: google.com) "
read domain

apt install apache2 -y
service apache2 restart

echo "

<VirtualHost *:80>

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined

</VirtualHost>

" > /etc/apache2/sites-available/000-default.conf

service apache2 restart

# a2enmod ssl rewrite proxy proxy_http
# echo "Disable default HTTP:80"
# a2dissite 000-default.conf
# a2ensite default-ssl.conf
# a2enmod proxy_connect
# service apache2 restart
echo "Updating.."
apt-get update
apt-get install wget
wget https://dl.eff.org/certbot-auto
chmod a+x certbot-auto
./certbot-auto --install-only
./certbot-auto certonly --apache --register-unsafely-without-email --non-interactive --quiet --agree-tos --redirect -d $domain

mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.bak 

echo "
	<VirtualHost *:80>

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        Redirect / https://$domain

        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined

	</VirtualHost>
" > /etc/apache2/sites-available/000-default.conf

echo "
<IfModule mod_ssl.c>
	<VirtualHost _default_:443>
		ServerAdmin webmaster@localhost

		DocumentRoot /var/www/html

		ServerName $domain
		Include /etc/letsencrypt/options-ssl-apache.conf

		SSLEngine on
		SSLProxyEngine on
		ProxyRequests off

		SSLProxyCheckPeerCN off
		SSLProxyCheckPeerName off

		ErrorLog \${APACHE_LOG_DIR}/error.log
		CustomLog \${APACHE_LOG_DIR}/access.log combined

		SSLEngine on

		SSLCertificateFile	/etc/letsencrypt/live/$domain/cert.pem
		SSLCertificateKeyFile /etc/letsencrypt/live/$domain/privkey.pem

		<FilesMatch \"\.(cgi|shtml|phtml|php)$\">
				SSLOptions +StdEnvVars
		</FilesMatch>
		<Directory /usr/lib/cgi-bin>
				SSLOptions +StdEnvVars
		</Directory>

	</VirtualHost>
</IfModule>
# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
" > /etc/apache2/sites-available/default-ssl.conf

a2enmod ssl rewrite proxy proxy_http
# echo "Disable default HTTP:80"
# a2dissite 000-default.conf
# a2dissite 000-default.conf
a2ensite default-ssl.conf
a2enmod proxy_connect
# service apache2 restart
service apache2 restart
