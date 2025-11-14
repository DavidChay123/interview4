pipeline {
    agent {
        docker {
            image 'python:3.9'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    
    environment {
        DOCKERHUB_CRED = 'dockerhub-creds'
        APP_SERVER_SSH = 'ssh-app-server'
        APP_SERVER_IP  = '98.92.159.105'
        APP_CONTAINER  = 'my-python-app'
        DOCKER_IMAGE   = 'davidchay123/my-python-app:latest'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/DavidChay123/interview4.git'
            }
        }
        
        stage('Lint') {
            steps {
                sh '''
                    pip install --upgrade pip
                    pip install flake8
                    flake8 . --exclude=venv,__pycache__,.git || true
                '''
            }
        }
        
        stage('Unit Tests') {
            steps {
                sh '''
                    if [ -f requirements.txt ]; then
                        pip install -r requirements.txt
                    fi
                    if [ -d tests ]; then
                        pip install pytest
                        pytest tests/ || true
                    else
                        echo "No tests directory found, skipping tests"
                    fi
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: DOCKERHUB_CRED,
                                                 usernameVariable: 'USERNAME',
                                                 passwordVariable: 'PASSWORD')]) {
                    sh '''
                        echo $PASSWORD | docker login -u $USERNAME --password-stdin
                        docker push ${DOCKER_IMAGE}
                    '''
                }
            }
        }
        
        stage('Deploy to App Server') {
            steps {
                sshagent([APP_SERVER_SSH]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${APP_SERVER_IP} '
                            docker pull ${DOCKER_IMAGE} &&
                            docker stop ${APP_CONTAINER} || true &&
                            docker rm ${APP_CONTAINER} || true &&
                            docker run -d --name ${APP_CONTAINER} -p 80:80 ${DOCKER_IMAGE}
                        '
                    """
                }
            }
        }
        
        stage('Health Check') {
            steps {
                sh "sleep 5 && curl -f http://${APP_SERVER_IP} || exit 1"
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