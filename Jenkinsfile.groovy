pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE_NAME = "app"  // Replace spaces with underscores or remove spaces
        ECR_REPO_URL = "255058516901.dkr.ecr.us-east-1.amazonaws.com/ecr-repo"  // Update with your ECR repository URL
        AWS_DEFAULT_REGION = "us-east-1"
        K8S_YAML_FILE = "deployment.yml"  // Update with the correct path to your Kubernetes YAML file
        DOCKER_TAG = "${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
    }

    stages {
        stage('Build Docker image') {
            steps {
                script {
                    echo "Building Docker image"
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Authenticate Docker with ECR') {
            steps {
                script {
                    echo "Authenticating Docker with ECR"
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URL}"
                }
            }
        }

        stage('Tag Docker image') {
            steps {
                script {
                    echo "Tagging Docker image"
                    sh "docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${ECR_REPO_URL}:${BUILD_NUMBER}"
                }
            }
        }

        stage('Push Docker image to ECR') {
            steps {
                script {
                    echo "Pushing Docker image to ECR"
                    sh "docker push ${ECR_REPO_URL}:${BUILD_NUMBER}"
                }
            }
        }

        stage('Update Kubernetes YAML file') {
            steps {
                script {
                    echo "Updating Kubernetes YAML file with ECR repository URL"
                    sh "sed -i 's#image:.*#image: ${ECR_REPO_URL}:${BUILD_NUMBER}#' ${K8S_YAML_FILE}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Deploying to Kubernetes"
                    sh "kubectl apply -f ${K8S_YAML_FILE}"
                }
            }
        }
    }
}
