#!/bin/bash
sudo -i 
apt-get update -y && apt-get upgrade -y 
curl https://get.docker.com / | bash
apt-get update -y && apt-get upgrade -y
usermod -aG docker ubuntu 