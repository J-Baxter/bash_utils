#!/bin/sh

# Update all packages and install dependencies
sudo apt-get install gdebi-core whois 
sudo apt-get update
sudo apt-get upgrade

# Install R
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo gpg --dearmor -o /usr/share/keyrings/r-project.gpg
echo "deb [signed-by=/usr/share/keyrings/r-project.gpg] https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" | sudo tee -a /etc/apt/sources.list.d/r-project.list
sudo apt update
sudo apt install --no-install-recommends r-base r-base-dev
sudo apt install libcurl4-openssl-dev libxml2-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev cmake

# Install R Studio
wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2023.06.1-524-amd64.deb #change to get latest version
sudo gdebi rstudio-server-2023.06.1-524-amd64.deb
sudo /bin/bash -c “echo ‘www-address=127.0.0.1’ >> /etc/rstudio/rserver.conf”
sudo rstudio-server restart

echo 'Please enter a username (this will be your login for RStudio):'
read username

echo 'Please enter a password (this will be your password for RStudio):'
read password

sudo useradd -m -p ‘mkpasswd -m sha-512 $password` -s /bin/bash $username

# or directly sudo useradd #username 

echo 'user added.'
echo 'RStudio set-up complete.'
