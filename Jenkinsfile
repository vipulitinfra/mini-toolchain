pipeline {
    agent any

    environment {
        APP_NAME = "mini-toolchain"
        DOCKER_IMAGE = "vipulitinfra/mini-toolchain:latest"
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo '🔹 Cloning repository...'
                checkout scm
            }
        }

        stage('Install Minikube (if not present)') {
            steps {
                echo '🔹 Checking/Installing Minikube...'
                sh 'bash setup-minikube.sh'
            }
        }

        stage('Build Node.js App') {
            steps {
                echo '🔹 Installing dependencies...'
                sh '''
                    if [ -f package.json ]; then
                      npm install
                    else
                      echo "No Node.js project found."
                    fi
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🔹 Building Docker image...'
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-token', variable: 'DOCKERHUB_TOKEN')]) {
                    sh '''
                        echo $DOCKERHUB_TOKEN | docker login -u vipulitinfra --password-stdin
                        docker push $DOCKER_IMAGE
                    '''
                }
            }
        }

        stage('Ansible Configuration') {
            steps {
                echo '🔹 Running Ansible playbook (if available)...'
                sh '''
                    if [ -d ansible ]; then
                      cd ansible && ansible-playbook setup.yml
                    else
                      echo "No Ansible playbook found."
                    fi
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                echo '🔹 Running Terraform...'
                sh '''
                    if [ -d terraform ]; then
                      cd terraform
                      terraform init
                      terraform apply -auto-approve
                    else
                      echo "No Terraform config found."
                    fi
                '''
            }
        }

        stage('Deploy to Minikube') {
            steps {
                echo '🔹 Deploying to Minikube...'
                sh '''
                    if [ -d k8s ]; then
                      kubectl apply -f k8s/
                    else
                      echo "No Kubernetes manifests found."
                    fi
                '''
            }
        }
    }

    post {
        success {
            echo "✅ CI/CD pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Please check logs."
        }
    }
}
