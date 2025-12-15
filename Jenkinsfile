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

        /* ===================== BUILD ===================== */
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

        /* ===================== CLEANUP ===================== */
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

        /* ===================== KUBERNETES DEPLOY ===================== */
        stage('Deploy to Kubernetes') {
            steps {
                echo '☸️ Deploying to Kubernetes...'
                withCredentials([string(credentialsId: 'kubeconfig-content', variable: 'KUBECONFIG_CONTENT')]) {
                  sh '''
    set +x

    echo "=== Setting up kubeconfig ==="
    mkdir -p ~/.kube

    # Write kubeconfig content safely using here-document
    cat > ~/.kube/config <<EOF
$KUBECONFIG_CONTENT
EOF

    chmod 600 ~/.kube/config

    echo "Checking cluster access..."
    kubectl cluster-info
'''

                }
            }
        }

        /* ===================== VERIFY ===================== */
        stage('Verify Deployment') {
            steps {
                echo '🔎 Verifying deployment...'
                withCredentials([string(credentialsId: 'kubeconfig-content', variable: 'KUBECONFIG_CONTENT')]) {
                    sh '''
                        export KUBECONFIG=~/.kube/config
                        kubectl get pods -n devops
                        kubectl get svc -n devops
                        kubectl get deployments -n devops
                    '''
                }
            }
        }
    }

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
