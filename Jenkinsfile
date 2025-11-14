pipeline {
    agent any
    
    environment {
        DOCKERHUB_CRED = 'dockerhub-creds'
        APP_SERVER_SSH = 'ssh-app-server'
        APP_SERVER_IP  = '98.92.159.105'
        APP_CONTAINER  = 'my-python-app'
        DOCKER_IMAGE   = 'davidchay123/my-python-app:latest'
        DOCKER_BIN     = '/usr/bin/docker'  // כאן נציין את הנתיב המלא ל-docker
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/DavidChay123/interview4.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                dir('app') {
                    sh "${DOCKER_BIN} build -t ${DOCKER_IMAGE} ."
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: DOCKERHUB_CRED,
                                                 usernameVariable: 'USERNAME',
                                                 passwordVariable: 'PASSWORD')]) {
                    sh """
                        echo \$PASSWORD | ${DOCKER_BIN} login -u \$USERNAME --password-stdin
                        ${DOCKER_BIN} push ${DOCKER_IMAGE}
                    """
                }
            }
        }
        
        stage('Deploy to App Server') {
            steps {
                sshagent([APP_SERVER_SSH]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${APP_SERVER_IP} '
                            export PATH=\$PATH:/usr/bin &&
                            ${DOCKER_BIN} pull ${DOCKER_IMAGE} &&
                            ${DOCKER_BIN} stop ${APP_CONTAINER} || true &&
                            ${DOCKER_BIN} rm ${APP_CONTAINER} || true &&
                            ${DOCKER_BIN} run -d --name ${APP_CONTAINER} -p 80:5000 ${DOCKER_IMAGE}
                        '
                    """
                }
            }
        }
        
        stage('Health Check') {
            steps {
                sh "sleep 10 && curl -f http://${APP_SERVER_IP} || exit 1"
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
