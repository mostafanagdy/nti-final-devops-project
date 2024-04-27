#!/bin/bash
sudo yum update -y
sudo yum install wget
sudo yum install -y docker
sudo yum install -y ca-certificates
sudo amazon-linux-extras install java-openjdk11
sudo amazon-linux-extras install epel -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
sudo dnf install java-17-amazon-corretto -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo service jenkins start
#sudo systemctl status jenkins
#systemctl status jenkins.service
#journalctl -xeu jenkins.service
#sudo systemctl restart jenkins.service
