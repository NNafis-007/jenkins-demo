pipeline {
    agent any

    environment {
        APP_NAME = "express-demo-app"
        APP_PORT = "3000"
    }

    stages {
        stage('Build') {
            steps {
                echo '========== BUILD STAGE =========='
                dir('app') {
                    sh '''
                        echo "Installing dependencies..."
                        npm install
                        echo "✓ Build completed successfully"
                    '''
                }
            }
        }

        stage('Test') {
            steps {
                echo '========== TEST STAGE =========='
                dir('app') {
                    sh '''
                        echo "Running unit tests..."
                        npm test
                        echo "✓ All tests passed"
                    '''
                }
            }
        }

        stage('Package') {
            steps {
                echo '========== PACKAGE STAGE =========='
                sh '''
                    echo "Building Docker image..."
                    docker build -t ${APP_NAME}:${BUILD_NUMBER} ./app
                    docker tag ${APP_NAME}:${BUILD_NUMBER} ${APP_NAME}:latest
                    echo "✓ Docker image built successfully"
                    docker images | grep ${APP_NAME}
                '''
            }
        }

        stage('Deploy') {
            steps {
                echo '========== DEPLOY STAGE =========='
                sh '''
                    echo "Stopping existing container..."
                    docker stop ${APP_NAME} || true
                    docker rm ${APP_NAME} || true
                    
                    echo "Deploying new container..."
                    docker run -d \
                        --name ${APP_NAME} \
                        --network jenkins-demo_ci-network \
                        -p ${APP_PORT}:${APP_PORT} \
                        ${APP_NAME}:latest
                    
                    echo "Waiting for application to start..."
                    sleep 5
                    
                    echo "✓ Application deployed successfully"
                    docker ps | grep ${APP_NAME}
                '''
            }
        }

        stage('Health-Check') {
            steps {
                echo '========== HEALTH-CHECK STAGE =========='
                script {
                    def retries = 10
                    def success = false
                    
                    for (int i = 0; i < retries; i++) {
                        try {
                            sh """
                                curl -f http://localhost:${APP_PORT}/health
                            """
                            echo "✓ Health check PASSED"
                            
                            // Get the health response
                            def healthResponse = sh(
                                script: "curl -s http://localhost:${APP_PORT}/health",
                                returnStdout: true
                            ).trim()
                            echo "Health Response: ${healthResponse}"
                            
                            // Test main endpoint
                            def mainResponse = sh(
                                script: "curl -s http://localhost:${APP_PORT}/",
                                returnStdout: true
                            ).trim()
                            echo "Main Endpoint: ${mainResponse}"
                            
                            success = true
                            break
                        } catch (Exception e) {
                            echo "Health check attempt ${i+1}/${retries} failed, retrying..."
                            sleep 3
                        }
                    }
                    
                    if (!success) {
                        error "❌ Health check FAILED after ${retries} attempts"
                    }
                }
            }
        }
    }

    post {
        success {
            echo '''
            ═══════════════════════════════════════
            ✓✓✓ PIPELINE SUCCESS ✓✓✓
            ═══════════════════════════════════════
            All stages completed successfully!
            
            Application Details:
            - Name: express-demo-app
            - URL: http://localhost:3000
            - Health: http://localhost:3000/health
            - Status: HEALTHY ✓
            ═══════════════════════════════════════
            '''
        }
        failure {
            echo '''
            ═══════════════════════════════════════
            ✗✗✗ PIPELINE FAILED ✗✗✗
            ═══════════════════════════════════════
            '''
            sh '''
                echo "Container logs:"
                docker logs ${APP_NAME} || true
            '''
        }
        always {
            echo "Build #${BUILD_NUMBER} completed"
        }
    }
}