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
                echo '📥 Cloning repository...'
                git branch: 'master',
                    url: 'https://github.com/MMoatez/ProjetStudentsManagement-DevOps.git'
            }
        }
        
        stage('Build with Maven') {
            steps {
                echo '🔨 Building project with Maven...'
                sh 'mvn clean package -DskipTests'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                script {
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:build-${BUILD_NUMBER}
                        echo "✅ Image built: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    """
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                echo '🚀 Pushing Docker image to Docker Hub...'
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'dockerhub-credentials',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )
                    ]) {
                        sh """
                            set +x  # Désactive l'affichage des commandes pour la sécurité
                            echo "🔐 Logging into Docker Hub..."
                            echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin
                            
                            if [ \$? -eq 0 ]; then
                                echo "✅ Login successful"
                                set -x
                                
                                echo "📤 Pushing ${DOCKER_IMAGE}:${DOCKER_TAG}..."
                                docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                                
                                echo "📤 Pushing ${DOCKER_IMAGE}:build-${BUILD_NUMBER}..."
                                docker push ${DOCKER_IMAGE}:build-${BUILD_NUMBER}
                                
                                echo "🔓 Logging out..."
                                docker logout
                                
                                echo "✅ All images pushed successfully!"
                            else
                                echo "❌ Docker login failed!"
                                exit 1
                            fi
                        """
                    }
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                echo '🧹 Cleaning up local Docker images...'
                sh """
                    docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true
                    docker rmi ${DOCKER_IMAGE}:build-${BUILD_NUMBER} || true
                    docker image prune -f
                """
            }
        }
    }
    
    post {
        success {
            echo '✅ =========================================='
            echo '✅  Pipeline completed successfully!'
            echo '✅ =========================================='
            echo "📦 Images disponibles sur Docker Hub:"
            echo "   • ${DOCKER_IMAGE}:${DOCKER_TAG}"
            echo "   • ${DOCKER_IMAGE}:build-${BUILD_NUMBER}"
            echo ''
            echo '🌐 Voir sur: https://hub.docker.com/r/moatezmathlouthi/projetstudents'
        }
        failure {
            echo '❌ =========================================='
            echo '❌  Pipeline failed!'
            echo '❌ =========================================='
            echo '📋 Vérifications à faire:'
            echo '   1. Les credentials Docker Hub sont corrects'
            echo '   2. Le token a les permissions Read/Write/Delete'
            echo '   3. Le repository Docker Hub existe'
        }
        always {
            echo '🧹 Cleaning workspace...'
            cleanWs()
        }
    }
}
```

---

## 🔐 Guide Complet : Création du Token Docker Hub

### **Étape par Étape avec Captures d'écran mentales** 😄

1. **Connexion à Docker Hub**
```
   👤 Va sur hub.docker.com
   🔑 Connecte-toi avec ton compte
```

2. **Accéder aux Tokens**
```
   ⚙️ Clique sur ton avatar (en haut à droite)
   📋 "Account Settings"
   🔒 Onglet "Security"
```

3. **Créer un Nouveau Token**
```
   ➕ Bouton "New Access Token"
   
   📝 Access Token Description: jenkins-full-access
   
   ✅ Access permissions:
      ☑️ Read, Write, Delete  ← TRÈS IMPORTANT !
      (PAS "Read-only")
   
   🔵 Generate
```

4. **Copier le Token**
```
   📋 Un token apparaît (une longue chaîne)
   ⚠️  COPIE-LE MAINTENANT ! Tu ne pourras plus le voir
   📝 Garde-le dans un fichier temporaire
```

5. **Mettre à jour Jenkins**
```
   Jenkins → Manage Jenkins → Credentials
   → (global) → dockerhub-credentials → Update
   
   Username: moatezmathlouthi
   Password: [COLLE TON NOUVEAU TOKEN ICI]
   
   💾 Save
