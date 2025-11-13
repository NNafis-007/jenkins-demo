pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "express-ci-demo:jenkins-${env.BUILD_NUMBER}"
        APP_NAME = "express-ci-demo"
        APP_PORT = "3000"
    }

    stages {
        stage('Checkout') {
            steps {
                echo '=== Stage: Checkout ==='
                checkout scm
                echo 'Source code checked out successfully'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '=== Stage: Install Dependencies ==='
                sh '''
                  echo "Installing npm dependencies..."
                  docker run --rm \
                    -v "$PWD":/usr/src/app \
                    -w /usr/src/app \
                    node:18-alpine \
                    sh -c "npm install"
                  echo "Dependencies installed successfully"
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                echo '=== Stage: Unit Tests ==='
                sh '''
                  echo "Running unit tests..."
                  docker run --rm \
                    -v "$PWD":/usr/src/app \
                    -w /usr/src/app \
                    node:18-alpine \
                    sh -c "npm test"
                  echo "All tests passed successfully!"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '=== Stage: Build Docker Image ==='
                sh """
                  echo "Building Docker image: ${DOCKER_IMAGE}"
                  docker build -t ${DOCKER_IMAGE} .
                  echo "Docker image built successfully"
                  docker images | grep express-ci-demo
                """
            }
        }

        stage('Package & Deploy') {
            steps {
                echo '=== Stage: Package & Deploy ==='
                sh '''
                  echo "Stopping any existing containers..."
                  docker compose -f docker-compose.yml down || true
                  
                  echo "Creating deployment configuration..."
                  # Create a temporary docker-compose file with the build-specific image
                  cat docker-compose.yml | sed "s|image: express-ci-demo:latest|image: ${DOCKER_IMAGE}|" > docker-compose.jenkins.yml
                  
                  echo "Deploying application with Docker Compose..."
                  docker compose -f docker-compose.jenkins.yml up -d
                  
                  echo "Waiting for container to start..."
                  sleep 5
                  
                  echo "Container status:"
                  docker ps | grep express-ci-demo || true
                '''
            }
        }

        stage('Health Check') {
            steps {
                echo '=== Stage: Health Check ==='
                script {
                    echo "Running health check script..."
                    sh 'chmod +x healthcheck.sh'
                    def healthResult = sh(
                        script: './healthcheck.sh',
                        returnStdout: true
                    ).trim()
                    echo healthResult
                    
                    // Verify container is running
                    def containerStatus = sh(
                        script: "docker inspect -f '{{.State.Running}}' express-ci-demo",
                        returnStdout: true
                    ).trim()
                    
                    if (containerStatus == 'true') {
                        echo "✓ Container is running"
                    } else {
                        error "✗ Container is not running"
                    }
                    
                    echo "=== DEPLOYMENT SUCCESS ==="
                    echo "Application is running at: http://localhost:${APP_PORT}"
                    echo "Health endpoint: http://localhost:${APP_PORT}/health"
                }
            }
        }

        stage('Display Application Status') {
            steps {
                echo '=== Stage: Application Status ==='
                sh '''
                  echo "====================================="
                  echo "APPLICATION DEPLOYMENT SUMMARY"
                  echo "====================================="
                  echo "Build Number: ${BUILD_NUMBER}"
                  echo "Image: ${DOCKER_IMAGE}"
                  echo "Container: express-ci-demo"
                  echo "Port: ${APP_PORT}"
                  echo ""
                  echo "Container Details:"
                  docker ps --filter "name=express-ci-demo" --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}"
                  echo ""
                  echo "Container Logs (last 10 lines):"
                  docker logs --tail 10 express-ci-demo
                  echo ""
                  echo "====================================="
                  echo "HEALTH STATUS: OK ✓"
                  echo "====================================="
                '''
            }
        }
    }

    post {
        success {
            echo '=== PIPELINE SUCCESS ==='
            echo 'All stages completed successfully!'
            echo "Application is running at: http://localhost:${APP_PORT}"
        }
        failure {
            echo '=== PIPELINE FAILURE ==='
            echo 'Pipeline failed. Cleaning up...'
            sh '''
              docker compose -f docker-compose.jenkins.yml down || true
              docker logs express-ci-demo || true
            '''
        }
        always {
            echo '=== Cleanup (Optional) ==='
            echo 'To stop the application, run: docker compose -f docker-compose.jenkins.yml down'
            // Uncomment below to auto-cleanup after pipeline
            // sh 'docker compose -f docker-compose.jenkins.yml down || true'
        }
    }
}
