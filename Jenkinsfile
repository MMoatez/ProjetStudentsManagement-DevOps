pipeline {
    agent any

    tools {
        jdk 'JAVA_HOME'
        maven 'M2_HOME'
    }

    environment {
        DOCKER_IMAGE = 'MoatezMathlouthi/projetstudents'   
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

        stage('Build & Push Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {

                    // Build image
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."

                    echo 'Pushing Docker image to Docker Hub...'

                    // Login & push
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'dockerhub-credentials', 
                            usernameVariable: 'DOCKER_USERNAME', 
                            passwordVariable: 'DOCKER_PASSWORD'
                        )
                    ]) {
                        sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
