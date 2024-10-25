pipeline {
    agent any

    environment {
        // Docker image name and version based on Jenkins build number
        IMAGE_NAME = "<DOCKERHUB_USERNAME>/django-app"
        IMAGE_TAG = "${env.BUILD_ID}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Clone the Django project from GitHub
                git branch: 'main', url: '<GITHUB_REPO_URL>'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image
                    dockerImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Log in to Docker Hub and push the image
                    docker.withRegistry('', 'docker-hub-credentials') {
                        dockerImage.push()
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                // Use SSH to deploy to a target EC2 instance
                sshagent(credentials: ['ec2-ssh-credentials']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ec2-user@<TARGET_EC2_IP> "
                        docker pull ${IMAGE_NAME}:${IMAGE_TAG} &&
                        docker stop django-app || true &&
                        docker rm django-app || true &&
                        docker run -d -p 80:8000 --name django-app ${IMAGE_NAME}:${IMAGE_TAG}"
                    '''
                }
            }
        }
    }

    post {
        always {
            // Clean up unused Docker images to save space
            script {
                docker.image("${IMAGE_NAME}:${IMAGE_TAG}").remove()
            }
        }
        success {
            echo 'Deployment was successful!'
        }
        failure {
            echo 'Deployment failed. Please check the logs.'
        }
    }
}
