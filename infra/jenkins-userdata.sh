#!/bin/bash

# Update system
apt-get update -y

# Install Java (required for Jenkins)
apt-get install -y fontconfig openjdk-17-jre

# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

apt-get update -y
apt-get install -y jenkins

# Start Jenkins
systemctl enable jenkins
systemctl start jenkins

# Install Docker
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

# Add Jenkins user to Docker group
usermod -aG docker jenkins

# Restart Jenkins so Docker group applies
systemctl restart jenkins
