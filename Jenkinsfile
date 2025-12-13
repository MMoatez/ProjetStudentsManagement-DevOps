pipeline {
    agent any
    
    tools {
        jdk 'JAVA_HOME'
        maven 'M2_HOME'
    }
    
    environment {
        DOCKER_IMAGE = 'moatezmathlouthi/projetstudents'
        DOCKER_TAG = 'latest'
    }
    
    stages {
        stage('GIT') {
            steps {
                echo 'Cloning repository...'
                git branch: 'master',
                    url: 'https://github.com/MMoatez/ProjetStudentsManagement-DevOps.git'
            }
        }
        
        stage('Build with Maven') {
            steps {
                echo 'Building project with Maven...'
                sh 'mvn clean package -DskipTests'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    """
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'dockerhub-credentials',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )
                    ]) {
                        sh """
                            echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                            docker logout
                        """
                    }
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                echo 'Cleaning up unused Docker images...'
                sh """
                    docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true
                    docker rmi ${DOCKER_IMAGE}:${BUILD_NUMBER} || true
                    docker system prune -f
                """
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline completed successfully!'
            echo "Image pushed: ${DOCKER_IMAGE}:${DOCKER_TAG}"
            echo "Image also tagged as: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
        }
        failure {
            echo '❌ Pipeline failed!'
            echo 'Check the logs above for details.'
        }
        always {
            echo 'Cleaning workspace...'
            cleanWs()
        }
    }
}
