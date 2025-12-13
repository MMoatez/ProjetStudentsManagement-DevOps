pipeline {
    agent any
    
    tools {
        jdk 'JAVA_HOME'
        maven 'M2_HOME'
    }
    
    environment {
        DOCKER_IMAGE = 'moatezmathlouthi/projetstudents'
        DOCKER_TAG = 'latest'
        // Ajout de la registry Docker Hub
        DOCKER_REGISTRY = 'https://index.docker.io/v1/'
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
        
        stage('Build & Push Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    // Construction de l'image
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                    
                    echo 'Pushing Docker image to Docker Hub...'
                    // Utilisation de docker.withRegistry pour une meilleure gestion
                    docker.withRegistry("${DOCKER_REGISTRY}", 'dockerhub-credentials') {
                        def dockerImage = docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}")
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                echo 'Cleaning up unused Docker images...'
                sh "docker system prune -f"
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline completed successfully!'
            echo "Image pushed: ${DOCKER_IMAGE}:${DOCKER_TAG}"
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
