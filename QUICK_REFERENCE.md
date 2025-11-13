# 🚀 Quick Reference Card - CI/CD Pipeline

## Essential Commands

### Start Jenkins (Docker-in-Docker)
```powershell
cd jenkins
docker compose -f docker-compose.jenkins.yml up -d --build
```

### Get Jenkins Initial Password
```powershell
docker exec jenkins-ci cat /var/jenkins_home/secrets/initialAdminPassword
```

### Access Jenkins
```
http://localhost:8080
```

---

## Copy Project to Jenkins Workspace

```powershell
# Copy all files
docker cp app.js jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
docker cp package.json jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
docker cp Dockerfile jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
docker cp docker-compose.yml jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
docker cp healthcheck.sh jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
docker cp tests jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/

# Make healthcheck executable
docker exec jenkins-ci chmod +x /var/jenkins_home/workspace/express-ci-demo/healthcheck.sh
```

**OR use the setup script:**
```powershell
.\setup.ps1
# Choose option 3
```

---

## Create Jenkins Pipeline Job

1. Jenkins → New Item
2. Name: `express-ci-demo`
3. Type: Pipeline
4. Pipeline → Definition: "Pipeline script"
5. Copy entire Jenkinsfile content
6. Modify the Checkout stage to:
```groovy
stage('Checkout') {
    steps {
        echo '=== Stage: Checkout ==='
        sh 'pwd && ls -la'
        echo 'Working directory verified'
    }
}
```
7. Save → Build Now

---

## Verify Application

### Check Running Containers
```powershell
docker ps
```

### Test Endpoints
```powershell
# Main page
curl http://localhost:3000

# Health endpoint
curl http://localhost:3000/health
```

### Run Health Check
```bash
# From project directory
bash healthcheck.sh

# OR from Jenkins container
docker exec jenkins-ci bash /var/jenkins_home/workspace/express-ci-demo/healthcheck.sh
```

### View Logs
```powershell
# Application logs
docker logs express-ci-demo

# Jenkins logs
docker logs jenkins-ci
```

---

## Screenshots to Capture

1. Jenkins Dashboard (successful build)
2. Blue Ocean Pipeline (all green)
3. Console Output - Tests passing
4. Console Output - Health check success
5. Browser: http://localhost:3000
6. Browser: http://localhost:3000/health
7. PowerShell: `docker ps` output
8. Health check script output

---

## Cleanup

### Stop Application Only
```powershell
docker compose down
```

### Stop Everything
```powershell
docker compose down
cd jenkins
docker compose -f docker-compose.jenkins.yml down
```

### Complete Cleanup (removes data)
```powershell
docker compose down -v
cd jenkins
docker compose -f docker-compose.jenkins.yml down -v
```

---

## Troubleshooting

### Jenkins can't access Docker
```powershell
cd jenkins
docker compose -f docker-compose.jenkins.yml restart
```

### Port 3000 already in use
```powershell
docker ps -a
docker stop express-ci-demo
docker rm express-ci-demo
```

### Check Docker socket permissions (in Jenkins)
```powershell
docker exec -it jenkins-ci ls -la /var/run/docker.sock
```

---

## Pipeline Stages Overview

```
┌─────────────────────────────────────────┐
│ 1. Checkout                             │
│    ↓ Get source code                    │
├─────────────────────────────────────────┤
│ 2. Install Dependencies                 │
│    ↓ npm install (in Docker)            │
├─────────────────────────────────────────┤
│ 3. Unit Tests                           │
│    ↓ npm test (Jest)                    │
├─────────────────────────────────────────┤
│ 4. Build Docker Image                   │
│    ↓ docker build                       │
├─────────────────────────────────────────┤
│ 5. Package & Deploy                     │
│    ↓ docker compose up                  │
├─────────────────────────────────────────┤
│ 6. Health Check                         │
│    ↓ healthcheck.sh                     │
├─────────────────────────────────────────┤
│ 7. Display Application Status           │
│    ✓ SUCCESS                            │
└─────────────────────────────────────────┘
```

---

## File Structure

```
jenkins-demo/
├── app.js                    ← Express app
├── package.json              ← Dependencies
├── Dockerfile                ← App container
├── docker-compose.yml        ← App deployment
├── Jenkinsfile              ← Pipeline definition
├── healthcheck.sh           ← Health verification
├── tests/
│   └── app.test.js          ← Unit tests
├── jenkins/
│   ├── Dockerfile           ← Jenkins + Docker
│   └── docker-compose.jenkins.yml
├── README.md                ← Full documentation
├── SETUP_GUIDE.md          ← Step-by-step guide
├── DELIVERABLES.md         ← Project summary
└── setup.ps1               ← Automation script
```

---

## Key URLs

- Jenkins UI: http://localhost:8080
- Application: http://localhost:3000
- Health: http://localhost:3000/health

---

## Quick Test

```powershell
# 1. Start Jenkins
cd jenkins; docker compose -f docker-compose.jenkins.yml up -d --build

# 2. Get password
docker exec jenkins-ci cat /var/jenkins_home/secrets/initialAdminPassword

# 3. Open Jenkins
start http://localhost:8080

# 4. Copy files (after Jenkins setup)
.\setup.ps1  # Option 3

# 5. Create pipeline job in Jenkins UI
# 6. Build Now
# 7. Test app
curl http://localhost:3000
```

---

**For detailed instructions, see SETUP_GUIDE.md**
