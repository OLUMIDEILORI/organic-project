pipeline {
    agent any

    environment {
        GIT_REPO_URL = 'https://github.com/OLUMIDEILORI/organic-project.git'
        BRANCH_NAME = 'main'
        DOCKER_IMAGE_NAME = 'your-django-app:latest'
        AWS_INSTANCE_IP = '44.212.38.34'
        SSH_KEY_PATH = credentials('olu-aws-ssh-key') // Using the added Jenkins SSH key
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: BRANCH_NAME, url: GIT_REPO_URL
            }
        }

        stage('Build Docker Image') {
            steps {
                docker.build(DOCKER_IMAGE_NAME)
            }
        }

        stage('Push Docker Image to Registry') {
            steps {
                sh "docker tag ${DOCKER_IMAGE_NAME} your-registry-url/${DOCKER_IMAGE_NAME}"
                sh "docker push your-registry-url/${DOCKER_IMAGE_NAME}"
            }
        }

        stage('Deploy to AWS') {
            steps {
                sshagent (credentials: ['olu-aws-ssh-key']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@${AWS_INSTANCE_IP} << EOF
                    docker pull your-registry-url/${DOCKER_IMAGE_NAME}
                    docker stop \$(docker ps -q --filter ancestor=your-registry-url/${DOCKER_IMAGE_NAME})
                    docker run -d -p 80:8000 your-registry-url/${DOCKER_IMAGE_NAME}
                    EOF
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment completed successfully.'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}

