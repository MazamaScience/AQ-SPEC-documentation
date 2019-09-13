################################################################################
# Makefile for provisioning Ubuntu 18.04 with Docker and Apache

update_repositories:
	sudo apt --assume-yes update

# From https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04
install_docker:
	# Uninstall Old Versions of Docker
	sudo apt --assume-yes remove docker docker-engine docker.io 
	# Install Docker    
	sudo apt --assume-yes install docker.io
	# Start and Automate Docker
	sudo systemctl start docker
	sudo systemctl enable docker
	# Don't require sudo to execute docker
	sudo usermod -aG docker ${USER}
	# Test
	###docker --version

# From https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04
install_official_docker:
	# Download Dependencies
	sudo apt --assume-yes install sudo apt --assume-yes-transport-https ca-certificates curl software-properties-common
	# Add Docker’s GPG Key    
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt --assume-yes-key add –
	# Install the Docker Repository
	add-sudo apt --assume-yes-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable" 
	# Update Repositories
	sudo apt --assume-yes update
	# Install Latest Version of Docker
	sudo apt --assume-yes install docker-ce
	# Start and Automate Docker
	sudo systemctl start docker
	sudo systemctl enable docker
	# Test
	###docker --version

# From https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-ubuntu-18-04-quickstart
install_apache:
	# Install Apache
	sudo apt --assume-yes install apache2
	# Adjust the Firewall
	sudo ufw allow 'Apache'
	# Test
	###sudo systemctl status apache2
	# Set up Virtual Hosts (recommended)
	# TODO
	# Start Apache
	sudo systemctl restart apache2

setup: update_repositories install_docker install_apache
	@echo ""
	@echo "All Done!"
	@echo ""
	@echo "Please log out and back in before continuing"
	@echo ""

################################################################################
# Targets for the data archive under /var/www/html/data

create_archive_dirs:
	sudo mkdir -p /var/www/html/data/PurpleAir/airsensor/2018
	sudo mkdir -p /var/www/html/data/PurpleAir/airsensor/2019
	sudo mkdir -p /var/www/html/data/PurpleAir/airsensor/2020
	sudo mkdir -p /var/www/html/data/PurpleAir/airsensor/latest
	sudo mkdir -p /var/www/html/data/PurpleAir/logs
	sudo mkdir -p /var/www/html/data/PurpleAir/pas/2018
	sudo mkdir -p /var/www/html/data/PurpleAir/pas/2019
	sudo mkdir -p /var/www/html/data/PurpleAir/pas/2020
	sudo mkdir -p /var/www/html/data/PurpleAir/pat/2018
	sudo mkdir -p /var/www/html/data/PurpleAir/pat/2019
	sudo mkdir -p /var/www/html/data/PurpleAir/pat/2020
	sudo mkdir -p /var/www/html/data/PurpleAir/pat/latest
	sudo mkdir -p /var/www/html/data/PurpleAir/videos/2018
	sudo mkdir -p /var/www/html/data/PurpleAir/videos/2019
	sudo mkdir -p /var/www/html/data/PurpleAir/videos/2020

#install_data_archive:
#	sudo wget --directory-prefix /var/www/html/data/ --no-parent --no-host-directories --cut-dirs=1 --recursive http://smoke.mazamascience.com/data/PurpleAir




