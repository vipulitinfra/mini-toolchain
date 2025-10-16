pipeline {
    agent any

    environment {
        APP_NAME = "mini-toolchain"
        DOCKER_IMAGE = "vipulitinfra/mini-toolchain:latest"
        LOCAL_BIN = "$HOME/.local/bin"
        PATH = "$LOCAL_BIN:$PATH"
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo '🔹 Cloning repository...'
                checkout scm
            }
        }

        stage('Install Minikube') {
            steps {
                echo '🔹 Installing Minikube (no sudo)...'
                sh '''
                    mkdir -p $LOCAL_BIN
                    if ! command -v minikube &> /dev/null; then
                      echo "Downloading Minikube..."
                      curl -Lo $LOCAL_BIN/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
                      chmod +x $LOCAL_BIN/minikube
                    else
                      echo "Minikube already installed"
                    fi
                '''
            }
        }

        stage('Build Node.js App') {
            steps {
                echo '🔹 Installing Node.js dependencies if package.json exists...'
                sh '''
                    if [ -f package.json ]; then
                      npm install
                    else
                      echo "No Node.js project found, skipping..."
                    fi
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🔹 Building Docker image...'
                sh '''
                    docker build -t $DOCKER_IMAGE .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                echo '🔹 Pushing Docker image to Docker Hub...'
                withCredentials([string(credentialsId: 'dockerhub-token', variable: 'DOCKERHUB_TOKEN')]) {
                    sh '''
                        echo $DOCKERHUB_TOKEN | docker login -u vipulitinfra --password-stdin
                        docker push $DOCKER_IMAGE
                    '''
                }
            }
        }

        stage('Run Ansible') {
            steps {
                echo '🔹 Running Ansible playbook if exists...'
                sh '''
                    if [ -d ansible ]; then
                      cd ansible && ansible-playbook setup.yml
                    else
                      echo "No Ansible folder found, skipping..."
                    fi
                '''
            }
        }

        stage('Run Terraform') {
            steps {
                echo '🔹 Running Terraform if exists...'
                sh '''
                    if [ -d terraform ]; then
                      cd terraform
                      terraform init
                      terraform apply -auto-approve
                    else
                      echo "No Terraform folder found, skipping..."
                    fi
                '''
            }
        }

        stage('Deploy to Minikube') {
            steps {
                echo '🔹 Deploying Kubernetes manifests if exists...'
                sh '''
                    if [ -d k8s ]; then
                      kubectl apply -f k8s/
                    else
                      echo "No k8s folder found, skipping..."
                    fi
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check the logs above for details."
        }
    }
}

