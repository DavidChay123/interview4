#!/bin/bash

JENKINS_CLI="/var/lib/jenkins/jenkins-cli.jar"
JENKINS_URL="http://localhost:8080"

plugins=(
  workflow-aggregator
  git
  docker-workflow
  ssh-agent
  credentials-binding
)

for plugin in "${plugins[@]}"; do
  java -jar $JENKINS_CLI -s $JENKINS_URL install-plugin "$plugin"
done

systemctl restart jenkins
