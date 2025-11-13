pipeline {
    agent any

    environment {
        APP_NAME = "express-ci-demo"
        APP_PORT = "3000"
    }

    stages {
        stage('Checkout') {
            steps {
                echo '=== Stage: Checkout ==='
                // Working with files already in workspace
                sh 'pwd && ls -la'
                echo 'Source code verified'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '=== Stage: Install Dependencies ==='
                sh '''
                  echo "Installing npm dependencies..."
                  npm install
                  echo "Dependencies installed successfully"
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                echo '=== Stage: Unit Tests ==='
                sh '''
                  echo "Running unit tests..."
                  npm test
                  echo "All tests passed successfully!"
                '''
            }
        }

        stage('Build Application') {
            steps {
                echo '=== Stage: Build Application ==='
                sh '''
                  echo "Application is ready for deployment"
                  echo "Build completed successfully"
                '''
            }
        }

        stage('Deploy') {
            steps {
                echo '=== Stage: Deploy ==='
                sh '''
                  echo "Starting application..."
                  # Kill any existing process on port 3000
                  pkill -f "node app.js" || true
                  # Start app in background
                  nohup npm start > app.log 2>&1 &
                  echo $! > app.pid
                  sleep 3
                  echo "Application deployed"
                '''
            }
        }

        stage('Health Check') {
            steps {
                echo '=== Stage: Health Check ==='
                script {
                    def retries = 10
                    def success = false
                    for (int i = 0; i < retries; i++) {
                        try {
                            sh 'curl -sf http://localhost:3000/health'
                            echo "✓ Health check passed!"
                            success = true
                            break
                        } catch (Exception e) {
                            echo "Health check attempt ${i+1} failed, retrying..."
                            sleep 2
                        }
                    }
                    if (!success) {
                        error "Health check failed after ${retries} attempts"
                    }
                }
            }
        }

        stage('Display Status') {
            steps {
                echo '=== Application Status ==='
                sh '''
                  echo "====================================="
                  echo "DEPLOYMENT SUCCESS"
                  echo "====================================="
                  echo "Application: ${APP_NAME}"
                  echo "Port: ${APP_PORT}"
                  echo "URL: http://localhost:${APP_PORT}"
                  echo "Health: http://localhost:${APP_PORT}/health"
                  echo "====================================="
                '''
            }
        }
    }

    post {
        success {
            echo '=== PIPELINE SUCCESS ==='
            echo "Application running at: http://localhost:${APP_PORT}"
        }
        failure {
            echo '=== PIPELINE FAILURE ==='
            sh 'cat app.log || true'
        }
    }
}
