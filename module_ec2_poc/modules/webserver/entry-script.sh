#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
sudo service ssh reload
sudo docker run -d -p 8080:80 nginx

# sudo apt update -y && sudo snap install docker
# # sudo chmod 666 /var/run/docker.sock 
# sudo snap start docker
# # sudo usermod -aG docker ubuntu
# sudo docker run -d -p 8080:80 nginx

