pipeline {
    agent any

    environment {
        // Credentials IDs כפי שהכנסנו ב-Jenkins
        DOCKERHUB_CRED = 'dockerhub-creds'
        APP_SERVER_SSH = 'ssh-app-server'
        APP_SERVER_IP  = '98.92.159.105'  // כתובת App EC2 שלך
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
                sh 'python3 -m pip install --user flake8'
                sh '$HOME/.local/bin/flake8 .'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'python3 -m pip install --user -r requirements.txt'
                sh 'python3 -m pytest tests/'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build(DOCKER_IMAGE)
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: DOCKERHUB_CRED,
                                                 usernameVariable: 'USERNAME',
                                                 passwordVariable: 'PASSWORD')]) {
                    sh "echo $PASSWORD | docker login -u $USERNAME --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}"
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
                        docker run -d --name ${APP_CONTAINER} -p 80:5000 ${DOCKER_IMAGE}
                    '
                    """
                }
            }
        }

        stage('Health Check') {
            steps {
                sh "curl -f http://${APP_SERVER_IP} || exit 1"
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
