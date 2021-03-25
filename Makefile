################################################################################
# Makefile for provisioning Ubuntu 18.04 with Docker and Apache

update_repositories:
	sudo apt --assume-yes update

# From https://linuxize.com/post/how-to-install-and-use-docker-compose-on-ubuntu-18-04/
install_docker-compose:
	sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-Linux-x86_64" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	# Test
	###docker-compose --version

# From https://support.rstudio.com/hc/en-us/articles/213733868-Running-Shiny-Server-with-a-Proxy
install_apache_shiny:
	# Install Apache and dependencies
	sudo apt --assume-yes install apache2
	# Adjust the Firewall
	sudo ufw allow 'Apache'
	# Update Apache configuration to activate mod-proxy
	sudo a2enmod rewrite
	sudo a2enmod headers
	sudo a2enmod proxy
	sudo a2enmod proxy_http
	sudo a2enmod proxy_wstunnel
	# Copy in new 000-default.conf
	sudo cp shiny_000-default.conf /etc/apache2/sites-enabled/000-default.conf
	# Test
	###sudo apachectl configtest
	###sudo systemctl status apache2
	# Start Apache
	sudo systemctl restart apache2
