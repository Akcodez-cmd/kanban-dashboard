pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'ajith7550/kanban-dashboard'
        CONTAINER_NAME = 'kanban-dashboard'
        APP_PORT = '80'
        CONTAINER_PORT = '8080'
    }
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        stage('Lint') {
            steps {
                echo 'Running application lint...'

                sh '''
                    docker run --rm \
                      -v "$WORKSPACE:/app" \
                      -w /app \
                      node:22-alpine \
                      sh -c "npm ci && npm run lint"
                '''
            }
        }
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'

                sh '''
                    docker build \
                      -t ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                      -t ${DOCKER_IMAGE}:latest \
                      .
                '''
            }
        }
        stage('Docker Login') {
            steps {
                echo 'Logging into Docker Hub...'
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login \
                            -u "$DOCKER_USER" \
                            --password-stdin
                    '''
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                sh '''
                    docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE}:latest
                '''
            }
        }
        stage('Deploy to EC2') {
            steps {
                echo 'Deploying application container...'
                sh '''
                    docker pull ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    docker run -d \
                      --name ${CONTAINER_NAME} \
                      -p ${APP_PORT}:${CONTAINER_PORT} \
                      --restart unless-stopped \
                      --memory=512m \
                      --cpus=1 \
                      ${DOCKER_IMAGE}:${BUILD_NUMBER}
                '''
            }
        }
        stage('Health Check') {
            steps {
                echo 'Checking container health...'
                sh '''
                    for i in $(seq 1 12); do
                        STATUS=$(docker inspect \
                            --format='{{.State.Health.Status}}' \
                            ${CONTAINER_NAME} 2>/dev/null || true)
                        echo "Health status: $STATUS"
                        if [ "$STATUS" = "healthy" ]; then
                            echo "Application is healthy!"
                            exit 0
                        fi
                        sleep 5
                    done
                    echo "Application health check failed."
                    docker logs ${CONTAINER_NAME}
                    exit 1
                '''
            }
        }
    }
    post {
        success {
            echo '========================================='
            echo 'CI/CD PIPELINE SUCCESSFUL!'
            echo 'Application deployed successfully.'
            echo '========================================='
        }
        failure {
            echo '========================================='
            echo 'CI/CD PIPELINE FAILED!'
            echo 'Please check Jenkins console logs.'
            echo '========================================='
        }
        always {
            sh '''
                docker image prune -f || true
            '''
        }
    }
}