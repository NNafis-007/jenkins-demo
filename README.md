# CI/CD Pipeline with Jenkins and Docker

A complete CI/CD pipeline demonstration that builds, tests, packages, and deploys a Node.js Express application using Jenkins running in Docker (Docker-in-Docker setup).

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Pipeline Stages](#pipeline-stages)
- [Files Description](#files-description)
- [Usage](#usage)
- [Screenshots](#screenshots)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This project demonstrates a complete CI/CD pipeline using:
- **Jenkins** (running in Docker) for CI/CD automation
- **Docker** for containerization
- **Docker Compose** for orchestration
- **Node.js/Express** for the demo application
- **Jest/Supertest** for unit testing

The pipeline automatically:
1. ✅ Checks out source code
2. ✅ Installs dependencies
3. ✅ Runs unit tests
4. ✅ Builds Docker image
5. ✅ Deploys container using Docker Compose
6. ✅ Verifies health status

## ✨ Features

- **Docker-in-Docker (DinD)**: Jenkins runs inside Docker and can execute Docker commands
- **Declarative Jenkinsfile**: Clean, readable pipeline-as-code
- **Health Checks**: Automated verification of application health
- **Complete Testing**: Unit tests with Jest and Supertest
- **Production-Ready**: Includes health endpoints and proper error handling

## 📁 Project Structure

```
jenkins-demo/
├── app.js                          # Express application
├── package.json                    # Node.js dependencies
├── Dockerfile                      # Application container definition
├── docker-compose.yml              # Application deployment configuration
├── Jenkinsfile                     # CI/CD pipeline definition
├── healthcheck.sh                  # Health verification script
├── tests/
│   └── app.test.js                # Unit tests
├── jenkins/
│   ├── Dockerfile                  # Jenkins container with Docker support
│   └── docker-compose.jenkins.yml  # Jenkins deployment configuration
└── README.md                       # This file
```

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux) - version 20.10+
- **Docker Compose** - version 2.0+
- **Git** - for cloning the repository

### Verify Installation

```powershell
# Check Docker version
docker --version

# Check Docker Compose version
docker compose version

# Verify Docker is running
docker ps
```

## 🚀 Quick Start

### Step 1: Clone the Repository

```powershell
git clone <your-repo-url>
cd jenkins-demo
```

### Step 2: Start Jenkins

```powershell
# Navigate to Jenkins directory
cd jenkins

# Build and start Jenkins
docker compose -f docker-compose.jenkins.yml up -d --build

# Check Jenkins is running
docker ps
```

### Step 3: Access Jenkins

1. Open your browser and navigate to: **http://localhost:8080**

2. Get the initial admin password:

```powershell
docker exec jenkins-ci cat /var/jenkins_home/secrets/initialAdminPassword
```

3. Complete the Jenkins setup wizard:
   - Install suggested plugins
   - Create an admin user
   - Keep the default Jenkins URL

### Step 4: Configure Jenkins Job

1. In Jenkins, click **New Item**
2. Enter a name (e.g., "express-ci-demo")
3. Select **Pipeline** and click **OK**
4. Under **Pipeline** section:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: Path to your repository (or use local path)
   - Branch: ***/main** (or your branch name)
   - Script Path: **Jenkinsfile**
5. Click **Save**

### Step 5: Run the Pipeline

1. Click **Build Now** on your Jenkins job
2. Watch the pipeline execute through all stages
3. View the console output for detailed logs

### Step 6: Verify Deployment

After a successful pipeline run:

```powershell
# Check the application is running
curl http://localhost:3000

# Check health endpoint
curl http://localhost:3000/health

# Or run the health check script
bash healthcheck.sh
```

## 📊 Pipeline Stages

The Jenkins pipeline includes the following stages:

### 1. **Checkout**
- Pulls the latest code from the repository
- Ensures we're working with the current version

### 2. **Install Dependencies**
- Runs `npm install` inside a Node.js Docker container
- Installs all required packages

### 3. **Unit Tests**
- Executes `npm test` to run Jest tests
- Validates application functionality
- Pipeline fails if tests don't pass

### 4. **Build Docker Image**
- Creates a Docker image with tag: `express-ci-demo:jenkins-{BUILD_NUMBER}`
- Image includes the application and all dependencies

### 5. **Package & Deploy**
- Generates deployment configuration
- Deploys application using Docker Compose
- Starts the container on port 3000

### 6. **Health Check**
- Runs `healthcheck.sh` script
- Verifies container is running
- Tests `/health` endpoint
- Confirms application is responding correctly

### 7. **Display Application Status**
- Shows deployment summary
- Displays container details and logs
- Confirms overall health status

## 📄 Files Description

### Application Files

- **`app.js`**: Express server with two endpoints:
  - `/` - Returns "Hello World from CI/CD demo!"
  - `/health` - Returns `{"status": "ok"}` for health checks

- **`package.json`**: Defines dependencies and scripts
  - Dependencies: `express`
  - Dev Dependencies: `jest`, `supertest`

- **`tests/app.test.js`**: Unit tests for both endpoints

### Docker Files

- **`Dockerfile`**: Multi-stage build for the application
  - Based on `node:18-alpine`
  - Includes wget for health checks
  - Built-in Docker HEALTHCHECK

- **`docker-compose.yml`**: Production deployment configuration
  - Exposes port 3000
  - Includes health check configuration
  - Auto-restart policy

### Jenkins Files

- **`Jenkinsfile`**: Declarative pipeline with 7 stages
  - Environment variables for image naming
  - Error handling and cleanup
  - Detailed logging

- **`jenkins/Dockerfile`**: Custom Jenkins image
  - Based on `jenkins/jenkins:lts-jdk17`
  - Includes Docker CLI and Docker Compose
  - Pre-installed plugins: Blue Ocean, Docker Workflow

- **`jenkins/docker-compose.jenkins.yml`**: Jenkins deployment
  - Maps Docker socket for DinD
  - Persistent volume for Jenkins data
  - Ports: 8080 (UI), 50000 (agents)

### Scripts

- **`healthcheck.sh`**: Comprehensive health verification
  - Checks if container is running
  - Verifies Docker health status
  - Tests health endpoint with retries
  - Displays container logs if failing

## 💡 Usage

### Running Locally Without Jenkins

```powershell
# Build and run the application
docker compose up -d --build

# Test the application
curl http://localhost:3000
curl http://localhost:3000/health

# Run health check
bash healthcheck.sh

# View logs
docker logs express-ci-demo

# Stop the application
docker compose down
```

### Running Tests Locally

```powershell
# Install dependencies
npm install

# Run tests
npm test

# Run application
npm start
```

### Viewing Jenkins Logs

```powershell
# View Jenkins container logs
docker logs jenkins-ci -f

# View Jenkins home directory
docker exec -it jenkins-ci ls -la /var/jenkins_home
```

### Cleanup

```powershell
# Stop and remove application containers
docker compose down

# Stop Jenkins
cd jenkins
docker compose -f docker-compose.jenkins.yml down

# Remove all containers and volumes (WARNING: Deletes data)
docker compose down -v
cd jenkins
docker compose -f docker-compose.jenkins.yml down -v

# Remove built images
docker rmi express-ci-demo:latest
docker rmi $(docker images -q express-ci-demo)
```

## 📸 Screenshots

### Required Screenshots to Capture:

1. **Jenkins Dashboard** - Show the successful pipeline run
2. **Pipeline Stages** - Blue Ocean view showing all stages green
3. **Console Output** - Complete log showing all stages
4. **Health Check Success** - Terminal output of successful health check
5. **Application Running** - Browser showing `http://localhost:3000`

### How to Capture Console Output:

1. Click on the successful build number in Jenkins
2. Click **Console Output**
3. Scroll through and screenshot key sections:
   - Checkout stage
   - Test results
   - Docker build
   - Health check success
   - Final status summary

## 🔧 Troubleshooting

### Jenkins Can't Access Docker

**Problem**: "Cannot connect to the Docker daemon"

**Solution**:
```powershell
# On Windows, ensure Docker Desktop is running
# Restart Jenkins container with proper permissions
cd jenkins
docker compose -f docker-compose.jenkins.yml down
docker compose -f docker-compose.jenkins.yml up -d
```

### Port Already in Use

**Problem**: "Port 3000 is already allocated" or "Port 8080 is already allocated"

**Solution**:
```powershell
# Find what's using the port
netstat -ano | findstr :3000
netstat -ano | findstr :8080

# Stop existing containers
docker compose down
cd jenkins
docker compose -f docker-compose.jenkins.yml down

# Or change the port in docker-compose.yml
```

### Tests Failing

**Problem**: Unit tests fail during pipeline

**Solution**:
```powershell
# Run tests locally to debug
npm install
npm test

# Check test output for specific errors
```

### Health Check Timeout

**Problem**: Health check stage fails with timeout

**Solution**:
```powershell
# Check if container is running
docker ps | grep express-ci-demo

# Check container logs
docker logs express-ci-demo

# Manually test health endpoint
curl http://localhost:3000/health

# Increase timeout in healthcheck.sh (edit MAX_RETRIES)
```

### Jenkins Build Fails with Permission Denied

**Problem**: Permission denied when accessing `/var/run/docker.sock`

**Solution**:
```powershell
# On Linux/Mac, fix docker socket permissions
sudo chmod 666 /var/run/docker.sock

# Or add jenkins user to docker group
docker exec -u root jenkins-ci chmod 666 /var/run/docker.sock
```

### Cannot Remove Container

**Problem**: "Container is in use" or "Conflict. Unable to remove repository"

**Solution**:
```powershell
# Force stop and remove
docker stop express-ci-demo
docker rm express-ci-demo

# Force remove image
docker rmi -f express-ci-demo:latest
```

## 🎓 Learning Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [Jest Testing Framework](https://jestjs.io/docs/getting-started)

## 📝 Next Steps

To extend this project, consider:

1. **Add more stages**: Code quality checks (ESLint, SonarQube)
2. **Multi-environment deployment**: Dev, Staging, Production
3. **Secrets management**: Use Jenkins credentials for sensitive data
4. **Notification integration**: Slack/email notifications on build status
5. **Docker registry**: Push images to Docker Hub or private registry
6. **Kubernetes deployment**: Deploy to K8s instead of Docker Compose
7. **Security scanning**: Add container vulnerability scanning

## 📜 License

This project is for educational purposes.

## 👥 Contributing

Feel free to submit issues and enhancement requests!

---

**Happy Building! 🚀**
