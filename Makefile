################################################################################
# Makefile for provisioning Ubuntu 18.04 with Docker and Apache
#

update_repositories:
	apt-get update

# From https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04
install_docker:
	# Update Software Repositories
	###apt-get update
	# Uninstall Old Versions of Docker
	apt-get remove docker docker-engine docker.io 
	# Install Docker    
	apt install docker.io
	# Start and Automate Docker
	systemctl start docker
	systemctl enable docker
	# Test
	###docker --version

# From https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04
install_official_docker:
	# Update Software Repositories
	###apt-get update
	# Download Dependencies
	apt-get install apt-transport-https ca-certificates curl software-properties-common
	# Add Docker’s GPG Key    
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add –
	# Install the Docker Repository
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable" 
	# Update Repositories
	apt-get update
	# Install Latest Version of Docker
	apt-get install docker-ce
	# Start and Automate Docker
	systemctl start docker
	systemctl enable docker
	# Test
	###docker --version

# From https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-ubuntu-18-04-quickstart
install_apache:
	# Update Software Repositories
	###apt-get update
	# Install Apache
	apt install apache2
	# Adjust the Firewall
	ufw allow 'Apache'
	# Test
	###systemctl status apache2
	# Set up Virtual Hosts (recommended)
	# TODO
	# Start Apache
	systemctl restart apache2

create_archive_dirs:
	mkdir -p /var/www/html/data/PurpleAir/airsensor/2018
	mkdir -p /var/www/html/data/PurpleAir/airsensor/2019
	mkdir -p /var/www/html/data/PurpleAir/airsensor/latest
	mkdir -p /var/www/html/data/PurpleAir/logs
	mkdir -p /var/www/html/data/PurpleAir/pas/2018
	mkdir -p /var/www/html/data/PurpleAir/pas/2019
	mkdir -p /var/www/html/data/PurpleAir/pat/2018
	mkdir -p /var/www/html/data/PurpleAir/pat/2019
	mkdir -p /var/www/html/data/PurpleAir/pat/latest
	mkdir -p /var/www/html/data/PurpleAir/videos/2018
	mkdir -p /var/www/html/data/PurpleAir/videos/2019

