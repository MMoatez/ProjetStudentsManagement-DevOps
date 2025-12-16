pipeline {
    agent any

    tools {
        jdk 'JAVA_HOME'
        maven 'M2_HOME'
    }

    environment {
        DOCKER_IMAGE = 'moatezmathlouthi/projetstudents'
        DOCKER_TAG   = 'latest'
    }

    stages {

        /* ===================== GIT ===================== */
        stage('Checkout') {
            steps {
                echo '📥 Cloning repository...'
                git branch: 'master',
                    url: 'https://github.com/MMoatez/ProjetStudentsManagement-DevOps.git'
            }
        }

        /* ===================== BUILD MAVEN ===================== */
        stage('Build Maven') {
            steps {
                echo '🔨 Building project with Maven...'
                sh 'mvn clean package -DskipTests'
            }
        }

        /* ===================== SONARQUBE ===================== */
        stage('SonarQube Analysis') {
            steps {
                echo '🔍 Running SonarQube analysis...'
                withSonarQubeEnv('SonarQubeServer') {
                    sh '''
                        mvn sonar:sonar \
                        -Dsonar.projectKey=student-management \
                        -DskipTests
                    '''
                }
            }
        }

        /* ===================== DOCKER BUILD ===================== */
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    '''
                }
            }
        }

        /* ===================== DOCKER PUSH ===================== */
        stage('Push Docker Image') {
            steps {
                echo '🚀 Pushing Docker image to Docker Hub...'
                sh '''
                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker logout
                '''
            }
        }

        /* ===================== DOCKER CLEANUP ===================== */
        stage('Docker Cleanup') {
            steps {
                echo '🧹 Cleaning local Docker images...'
                sh '''
                    docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true
                    docker rmi ${DOCKER_IMAGE}:${BUILD_NUMBER} || true
                    docker system prune -f
                '''
            }
        }

        /* ===================== KUBERNETES DEPLOY ===================== 
    stage('Deploy to Kubernetes') {
    steps {
        echo '☸️ Deploying to Kubernetes...'
        withCredentials([string(credentialsId:  'kubeconfig-content', variable: 'KUBECONFIG_BASE64')]) {
            sh '''
                mkdir -p ~/.kube
                echo "$KUBECONFIG_BASE64" | base64 -d > ~/.kube/config
                chmod 600 ~/.kube/config
                
                echo "Checking cluster access..."
                kubectl cluster-info

                echo "Creating namespace if needed..."
                kubectl get namespace devops || kubectl create namespace devops

                echo "Deploying MySQL..."
                kubectl apply -f kubernetes/mysql-deployment.yaml -n devops

                echo "Deploying Spring Boot..."
                kubectl apply -f kubernetes/spring-deployment.yaml -n devops

                echo "Restarting Spring deployment..."
                kubectl rollout restart deployment spring-app -n devops
            '''
        }
    }
}
*/
        /* ===================== VERIFY DEPLOYMENT ===================== 
        stage('Verify Deployment') {
            steps {
                echo '🔎 Verifying deployment...'
                withCredentials([file(credentialsId: 'kubeconfig-file', variable: 'KUBECONFIG')]) {
                    sh '''
                        mkdir -p ~/.kube
                        cp $KUBECONFIG ~/.kube/config
                        chmod 600 ~/.kube/config
                        kubectl get pods -n devops
                        kubectl get svc -n devops
                        kubectl get deployments -n devops
                    '''
                }
            }
        }*/


        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes...'
                script {
                    // Option 1: Use kubeconfig from Jenkins credentials (recommended)
                    // First, add your kubeconfig as a "Secret file" credential in Jenkins
                    // with ID 'kubeconfig-file', then uncomment the following:
                    /*
                    withCredentials([file(credentialsId: 'kubeconfig-file', variable: 'KUBECONFIG')]) {
                        sh '''
                            export KUBECONFIG=${KUBECONFIG}
                            kubectl config view --minify
                            kubectl cluster-info
                            kubectl get nodes
                        '''
                    }
                    */
                    
                    // Option 2: Use kubeconfig content from secret text credential
                    // Add your kubeconfig content as a "Secret text" credential with ID 'kubeconfig-content'
                    withCredentials([string(credentialsId: 'kubeconfig-content', variable: 'KUBECONFIG_CONTENT')]) {
                        sh """
                            set +x  # Disable command echoing to protect sensitive data
                            echo "=== Setting up kubectl configuration ==="
                            
                            # Create .kube directory if it doesn't exist
                            mkdir -p ~/.kube
                            
                            # Write kubeconfig content to file using cat with here-document
                            # Using unquoted delimiter so Groovy can expand the variable
                            cat > ~/.kube/config << KUBECONFIG_EOF
                            ${KUBECONFIG_CONTENT}
                            KUBECONFIG_EOF
                            
                            chmod 600 ~/.kube/config
                            
                            # Verify the file was written correctly
                            echo "Kubeconfig file created"
                            echo "File size: \$(wc -c < ~/.kube/config) bytes"
                            echo "First 3 lines:"
                            head -3 ~/.kube/config || true
                            
                            echo "=== Kubectl Configuration Diagnostics ==="
                            echo "Checking kubectl version..."
                            kubectl version --client || {
                                echo "ERROR: kubectl not found or not working"
                                exit 1
                            }
                            
                            echo "Checking current context..."
                            kubectl config current-context || {
                                echo "ERROR: No context set in kubeconfig"
                                exit 1
                            }
                            
                            echo "Checking kubeconfig..."
                            kubectl config view --minify || {
                                echo "ERROR: Could not view kubeconfig"
                                exit 1
                            }
                            
                            echo "Testing API server connectivity..."
                            if ! kubectl cluster-info 2>&1 | grep -q "Kubernetes control plane"; then
                                echo "WARNING: Could not reach Kubernetes API server"
                                echo "Attempting to continue with --validate=false..."
                            fi
                            
                            echo "Checking if namespace exists..."
                            if ! kubectl get namespace devops 2>/dev/null; then
                                echo "Creating devops namespace..."
                                kubectl create namespace devops || {
                                    echo "ERROR: Failed to create namespace"
                                    exit 1
                                }
                            fi
                            
                            echo "=== Applying Deployments ==="
                            echo "Applying MySQL deployment..."
                            kubectl apply -f kubernetes/mysql-deployment.yaml -n devops --validate=false || {
                                echo "ERROR: Failed to apply mysql-deployment.yaml"
                                exit 1
                            }
                            
                            echo "Applying Spring deployment..."
                            kubectl apply -f kubernetes/spring-deployment.yaml -n devops --validate=false || {
                                echo "ERROR: Failed to apply spring-deployment.yaml"
                                exit 1
                            }
                            
                            echo "Restarting Spring app deployment..."
                            kubectl rollout restart deployment spring-app -n devops || echo "INFO: Could not restart deployment (may not exist yet, will be created)"
                        """
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                script {
                    withCredentials([string(credentialsId: 'kubeconfig-content', variable: 'KUBECONFIG_CONTENT')]) {
                        sh '''
                            export KUBECONFIG=~/.kube/config
                            echo "=== Deployment Status ==="
                            kubectl get pods -n devops || echo "Could not list pods"
                            kubectl get svc -n devops || echo "Could not list services"
                            kubectl get deployments -n devops || echo "Could not list deployments"
                        '''
                    }
                }
            }
        }

        
    }

    /* ===================== POST ===================== */
    post {
        success {
            echo '✅ Pipeline terminé avec succès'
            echo "🐳 Docker Image : ${DOCKER_IMAGE}:${DOCKER_TAG}"
        }
        failure {
            echo '❌ Pipeline échoué'
        }
        always {
            cleanWs()
        }
    }
}
