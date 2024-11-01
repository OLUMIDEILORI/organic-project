pipeline {
    agent any

    environment {
        GIT_REPO_URL = 'https://github.com/OLUMIDEILORI/organic-project.git'
        BRANCH_NAME = 'main'
        DOCKER_IMAGE_NAME = 'iloriadewale22/your-django-app'  // Change 'your-django-app' as needed
        IMAGE_TAG = 'latest'
        AWS_INSTANCE_IP = '44.212.38.34'
        SSH_KEY_PATH = credentials('olu-aws-ssh-key') // Jenkins SSH key ID
        DOCKER_CREDENTIALS_ID = 'docker-credentials' // Docker Hub credentials ID
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from the Git repository
                git branch: BRANCH_NAME, url: GIT_REPO_URL
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image with a specified tag
                    docker.build("${DOCKER_IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    // Login to Docker registry and push the image
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID,
                                                      usernameVariable: 'DOCKER_USER',
                                                      passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"
                        sh "docker push ${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Deploy to AWS') {
            steps {
                script {
                    // Use SSH to connect to the AWS instance and deploy the Docker image
                    sshagent (credentials: ['olu-aws-ssh-key']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${AWS_INSTANCE_IP} <<EOF
                        # Stop running containers
                        docker stop \$(docker ps -q --filter ancestor=${DOCKER_IMAGE_NAME}:${IMAGE_TAG}) || true
                        
                        # Pull the latest image
                        docker pull ${DOCKER_IMAGE_NAME}:${IMAGE_TAG}
                        
                        # Run the container
                        docker run -d -p 80:8000 ${DOCKER_IMAGE_NAME}:${IMAGE_TAG}
                        EOF
                        """
                    }
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
