pipeline {
    agent any 

    environment {
        GIT_REPO_URL = 'https://github.com/OLUMIDEILORI/organic-project.git'
        BRANCH_NAME = 'main'
        DOCKER_IMAGE_NAME = 'iloriadewale22/organic-django-app'  // Full Docker image name with registry username
        AWS_INSTANCE_IP = '3.83.151.2'
        SSH_KEY_PATH = '/var/lib/jenkins/olu-aws-ssh-key.pem'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Checkout the specified branch
                    git branch: BRANCH_NAME, url: GIT_REPO_URL
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image and tag it with the repository name
                    dir('.') {  // Using the root directory of the project
                        docker.build("${DOCKER_IMAGE_NAME}")
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Login to Docker Hub, tag, and push the Docker image
                    docker.withRegistry('', 'docker-hub-credentials') {  // Replace with Jenkins credentials ID
                        def image = docker.build("${DOCKER_IMAGE_NAME}")
                        image.push('latest')  // Pushes the image with the "latest" tag
                    }
                }
            }
        }

        stage('Deploy to AWS') {
            steps {
                script {
                    // Connect to the AWS instance and deploy the Docker container
                    sh """
                    ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no ubuntu@${AWS_INSTANCE_IP} "\
                    
                    # Pull the latest Docker image \
                    docker pull ${DOCKER_IMAGE_NAME} || true; \
                    
                    # Stop any running containers using the same image \
                    CONTAINER_ID=\$(docker ps -q --filter 'ancestor=${DOCKER_IMAGE_NAME}'); \
                    if [ -n '\$CONTAINER_ID' ]; then \
                        docker stop \$CONTAINER_ID; \
                        docker rm \$CONTAINER_ID; \
                    fi; \
                    
                    # Run the new container \
                    docker run -d -p 80:8000 ${DOCKER_IMAGE_NAME}:latest"
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
