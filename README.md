# Jenkins CI/CD Pipeline Demo

Complete CI/CD pipeline with Jenkins and Express.js demo application.

## Repository Structure

```
jenkins-demo/
├── app/                      # Demo application source code
│   ├── app.js               # Express application
│   ├── package.json         # Node.js dependencies
│   ├── Dockerfile           # App container definition
│   └── tests/
│       └── app.test.js      # Unit tests
├── Jenkinsfile              # Declarative pipeline
├── docker-compose.yml       # Both Jenkins & App services
├── healthcheck.sh           # Health verification script
└── README.md               # This file
```

## Quick Start

### 1. Start Services (Jenkins + App)

```bash
docker-compose up -d
```

This starts:
- Jenkins on http://localhost:8080
- Demo app on http://localhost:3000

### 2. Install Docker & Node.js in Jenkins

```bash
# Install Docker CLI
docker exec -u root jenkins-ci bash -c "apt-get update && apt-get install -y docker.io curl"

# Install Node.js 18
docker exec -u root jenkins-ci bash -c "curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs"

# Verify
docker exec jenkins-ci node --version
docker exec jenkins-ci npm --version
docker exec jenkins-ci docker --version
```

### 3. Copy Project Files to Jenkins

```bash
docker cp . jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
```

### 4. Create Pipeline in Jenkins

1. Open http://localhost:8080
2. Click **New Item**
3. Name: `express-ci-demo`
4. Type: **Pipeline**
5. Pipeline Definition: **Pipeline script from SCM**
   - SCM: **Git** (or use Pipeline script directly)
   - Repository URL: (your repo) or paste Jenkinsfile content
   - Script Path: `Jenkinsfile`
6. Click **Save**

### 5. Run the Pipeline

1. Click **Build Now**
2. View **Console Output** to see all stages

## Pipeline Stages

The Jenkinsfile defines 5 stages:

1. **Build** - Install npm dependencies
2. **Test** - Run unit tests with Jest
3. **Package** - Build Docker image
4. **Deploy** - Run container from image
5. **Health-Check** - Verify app is healthy

## Expected Console Output

```
========== BUILD STAGE ==========
Installing dependencies...
✓ Build completed successfully

========== TEST STAGE ==========
Running unit tests...
✓ All tests passed

========== PACKAGE STAGE ==========
Building Docker image...
✓ Docker image built successfully

========== DEPLOY STAGE ==========
Deploying new container...
✓ Application deployed successfully

========== HEALTH-CHECK STAGE ==========
✓ Health check PASSED
Health Response: {"status":"ok"}
Main Endpoint: Hello World from CI/CD demo!

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
```

## Verify Application

```bash
# Test main endpoint
curl http://localhost:3000

# Test health endpoint
curl http://localhost:3000/health

# Run health check script
bash healthcheck.sh
```

## Cleanup

```bash
# Stop all services
docker-compose down

# Remove volumes (deletes Jenkins data)
docker-compose down -v

# Remove built images
docker rmi express-demo-app:latest
```

## Troubleshooting

**Jenkins permissions error:**
```bash
docker exec -u root jenkins-ci chmod 666 /var/run/docker.sock
```

**Pipeline fails at build:**
- Ensure Node.js is installed in Jenkins container
- Verify files are copied to workspace

**Pipeline fails at package:**
- Ensure Docker is installed in Jenkins container
- Check Docker socket permissions

**Health check fails:**
- Check container logs: `docker logs express-demo-app`
- Verify app is running: `docker ps | grep express-demo-app`
