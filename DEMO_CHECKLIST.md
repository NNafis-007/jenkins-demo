# ✅ Pre-Demo Checklist & Execution Plan

## 📋 Before You Start

### System Requirements
- [ ] Docker Desktop is installed and running
- [ ] PowerShell is available
- [ ] Git is installed
- [ ] Ports 8080 and 3000 are free
- [ ] At least 4GB RAM available
- [ ] At least 5GB disk space available

### Verify Prerequisites
```powershell
docker --version          # Should show Docker version
docker ps                 # Should show running containers
docker compose version    # Should show compose version
```

---

## 🚀 Execution Plan (Step-by-Step)

### Phase 1: Setup Jenkins (15 minutes)

#### Step 1.1: Start Jenkins Container
```powershell
cd jenkins
docker compose -f docker-compose.jenkins.yml up -d --build
```
- [ ] Command executed successfully
- [ ] No error messages
- [ ] Jenkins container is running

#### Step 1.2: Verify Jenkins is Running
```powershell
docker ps
```
- [ ] See `jenkins-ci` container
- [ ] Status shows "Up"
- [ ] Ports 8080->8080 and 50000->50000 are mapped

#### Step 1.3: Get Initial Admin Password
```powershell
docker exec jenkins-ci cat /var/jenkins_home/secrets/initialAdminPassword
```
- [ ] Password displayed
- [ ] Password copied to notepad

**Wait 30 seconds for Jenkins to fully start**

#### Step 1.4: Access Jenkins UI
- [ ] Open http://localhost:8080 in browser
- [ ] Jenkins unlock page appears
- [ ] Paste admin password
- [ ] Click Continue

#### Step 1.5: Install Plugins
- [ ] Select "Install suggested plugins"
- [ ] Wait for installation (2-3 minutes)
- [ ] All plugins installed successfully

#### Step 1.6: Create Admin User
- [ ] Username: `admin`
- [ ] Password: `admin123` (or your choice)
- [ ] Full name: `Admin User`
- [ ] Email: `admin@example.com`
- [ ] Click "Save and Continue"

#### Step 1.7: Instance Configuration
- [ ] Keep default URL: http://localhost:8080/
- [ ] Click "Save and Finish"
- [ ] Click "Start using Jenkins"

✅ **Jenkins Setup Complete!**

---

### Phase 2: Prepare Project Files (5 minutes)

#### Step 2.1: Copy Files to Jenkins Workspace
From project root directory:

```powershell
# Go back to project root
cd ..

# Option 1: Use setup script
.\setup.ps1
# Choose option 3

# Option 2: Manual copy
docker exec jenkins-ci mkdir -p /var/jenkins_home/workspace/express-ci-demo
docker cp app.js jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
docker cp package.json jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
docker cp Dockerfile jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
docker cp docker-compose.yml jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
docker cp healthcheck.sh jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
docker cp tests jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
docker exec jenkins-ci chmod +x /var/jenkins_home/workspace/express-ci-demo/healthcheck.sh
```

- [ ] Files copied successfully
- [ ] No error messages

#### Step 2.2: Verify Files
```powershell
docker exec jenkins-ci ls -la /var/jenkins_home/workspace/express-ci-demo/
```
- [ ] All files present: app.js, package.json, Dockerfile, docker-compose.yml, healthcheck.sh, tests/

✅ **Files Ready!**

---

### Phase 3: Create Jenkins Pipeline (10 minutes)

#### Step 3.1: Create New Item
- [ ] In Jenkins UI, click "New Item"
- [ ] Name: `express-ci-demo`
- [ ] Select "Pipeline"
- [ ] Click "OK"

#### Step 3.2: Configure Pipeline
**General Section:**
- [ ] Description: `Complete CI/CD Pipeline Demo`

**Pipeline Section:**
- [ ] Definition: Select "Pipeline script"
- [ ] Copy Jenkinsfile content (open `Jenkinsfile` in editor)

**IMPORTANT: Modify the Checkout stage:**

Replace this:
```groovy
stage('Checkout') {
    steps {
        echo '=== Stage: Checkout ==='
        checkout scm
        echo 'Source code checked out successfully'
    }
}
```

With this:
```groovy
stage('Checkout') {
    steps {
        echo '=== Stage: Checkout ==='
        sh 'pwd && ls -la'
        echo 'Working directory verified'
    }
}
```

- [ ] Jenkinsfile content pasted and modified
- [ ] Checkout stage updated
- [ ] Click "Save"

✅ **Pipeline Created!**

---

### Phase 4: Run the Pipeline (5 minutes)

#### Step 4.1: Trigger Build
- [ ] Click "Build Now" (left sidebar)
- [ ] Build #1 appears in Build History

#### Step 4.2: Monitor Execution
- [ ] Click on build #1
- [ ] Click "Console Output"
- [ ] Watch stages execute

#### Step 4.3: Wait for Completion
Watch for these stages to complete:
- [ ] ✓ Checkout
- [ ] ✓ Install Dependencies
- [ ] ✓ Unit Tests
- [ ] ✓ Build Docker Image
- [ ] ✓ Package & Deploy
- [ ] ✓ Health Check
- [ ] ✓ Display Application Status

#### Step 4.4: Verify Success
- [ ] See "Finished: SUCCESS" at bottom
- [ ] No red error messages
- [ ] All stages show green checkmarks

✅ **Pipeline Successful!**

---

### Phase 5: Verify Application (5 minutes)

#### Step 5.1: Check Running Containers
```powershell
docker ps
```
- [ ] `jenkins-ci` is running
- [ ] `express-ci-demo` is running
- [ ] Port 3000 is mapped

#### Step 5.2: Test Main Endpoint
```powershell
curl http://localhost:3000
```
Or open in browser: http://localhost:3000
- [ ] Returns "Hello World from CI/CD demo!"

#### Step 5.3: Test Health Endpoint
```powershell
curl http://localhost:3000/health
```
Or open in browser: http://localhost:3000/health
- [ ] Returns `{"status":"ok"}`

#### Step 5.4: Run Health Check Script
```powershell
bash healthcheck.sh
```
Or:
```powershell
docker exec jenkins-ci bash /var/jenkins_home/workspace/express-ci-demo/healthcheck.sh
```
- [ ] Shows "HEALTH CHECK PASSED"
- [ ] All checks are green

#### Step 5.5: View Logs
```powershell
docker logs express-ci-demo
```
- [ ] Shows "Server running on port 3000"
- [ ] No error messages

✅ **Application Verified!**

---

## 📸 Phase 6: Capture Screenshots (20 minutes)

### Screenshot 1: Jenkins Dashboard
**What to capture:**
- [ ] Navigate to http://localhost:8080
- [ ] Show pipeline job with green build
- [ ] Build history visible
- [ ] File: `01-jenkins-dashboard.png`

### Screenshot 2: Blue Ocean View
**What to capture:**
- [ ] Click "Open Blue Ocean" (left sidebar)
- [ ] Select your pipeline
- [ ] Show all 7 stages in green
- [ ] File: `02-blueocean-pipeline.png`

### Screenshot 3: Console Output - Start
**What to capture:**
- [ ] Back to classic view
- [ ] Click build #1
- [ ] Click "Console Output"
- [ ] Scroll to top
- [ ] Capture: Started, Checkout, Install Dependencies stages
- [ ] File: `03-console-start.png`

### Screenshot 4: Console Output - Tests
**What to capture:**
- [ ] Scroll to Unit Tests stage
- [ ] Show "All tests passed successfully!"
- [ ] Show test output
- [ ] File: `04-console-tests.png`

### Screenshot 5: Console Output - Build & Deploy
**What to capture:**
- [ ] Scroll to Build Docker Image stage
- [ ] Show Deploy stage output
- [ ] File: `05-console-build-deploy.png`

### Screenshot 6: Console Output - Health Check
**What to capture:**
- [ ] Scroll to Health Check stage
- [ ] Show health check output
- [ ] Show "HEALTH CHECK PASSED"
- [ ] File: `06-console-health.png`

### Screenshot 7: Console Output - Success
**What to capture:**
- [ ] Scroll to bottom
- [ ] Show "PIPELINE SUCCESS"
- [ ] Show complete summary
- [ ] File: `07-console-success.png`

### Screenshot 8: Application - Main Page
**What to capture:**
- [ ] Open http://localhost:3000 in browser
- [ ] Show "Hello World from CI/CD demo!" message
- [ ] Show URL in address bar
- [ ] File: `08-app-main.png`

### Screenshot 9: Application - Health Endpoint
**What to capture:**
- [ ] Open http://localhost:3000/health in browser
- [ ] Show `{"status":"ok"}` JSON response
- [ ] Show URL in address bar
- [ ] File: `09-app-health.png`

### Screenshot 10: Docker Containers
**What to capture:**
- [ ] Run `docker ps` in PowerShell
- [ ] Show both jenkins-ci and express-ci-demo containers
- [ ] Show ports and status
- [ ] File: `10-docker-ps.png`

### Screenshot 11: Health Check Script
**What to capture:**
- [ ] Run `bash healthcheck.sh` (or via docker exec)
- [ ] Show complete output
- [ ] Show "HEALTH CHECK PASSED" at bottom
- [ ] File: `11-healthcheck-script.png`

### Screenshot 12: Jenkins Job Configuration (Optional)
**What to capture:**
- [ ] Show pipeline configuration page
- [ ] Show Jenkinsfile script section
- [ ] File: `12-jenkins-config.png`

✅ **Screenshots Captured!**

---

## 📝 Phase 7: Documentation Review (5 minutes)

### Files to Review
- [ ] README.md - Overall project documentation
- [ ] SETUP_GUIDE.md - Step-by-step setup
- [ ] PROJECT_SUMMARY.md - Executive summary
- [ ] DELIVERABLES.md - What was delivered
- [ ] QUICK_REFERENCE.md - Command reference

### Verify All Deliverables
- [ ] ✓ Jenkinsfile (Declarative pipeline)
- [ ] ✓ Dockerfile (Application container)
- [ ] ✓ docker-compose.yml (Deployment config)
- [ ] ✓ app.js (Demo application)
- [ ] ✓ tests/app.test.js (Unit tests)
- [ ] ✓ healthcheck.sh (Health verification)
- [ ] ✓ jenkins/Dockerfile (Jenkins DinD)
- [ ] ✓ jenkins/docker-compose.jenkins.yml (Jenkins deployment)
- [ ] ✓ Comprehensive documentation

✅ **Documentation Complete!**

---

## 🎬 Phase 8: Demo Preparation (10 minutes)

### Prepare Talking Points
- [ ] Explain Docker-in-Docker setup
- [ ] Walk through pipeline stages
- [ ] Show automated testing
- [ ] Demonstrate health checks
- [ ] Show application running

### Demo Flow
1. [ ] Show project structure and files
2. [ ] Show Jenkins UI and pipeline
3. [ ] Trigger a build (or show existing successful build)
4. [ ] Walk through console output
5. [ ] Show Blue Ocean visualization
6. [ ] Access application in browser
7. [ ] Run health check script
8. [ ] Explain each component

### Backup Plans
- [ ] Screenshots ready if live demo fails
- [ ] Know how to restart containers
- [ ] Have commands ready in notepad
- [ ] Know troubleshooting steps

✅ **Demo Ready!**

---

## 🧪 Testing Checklist

### Before Demo
- [ ] Run complete pipeline at least once
- [ ] Verify all stages pass
- [ ] Test application endpoints
- [ ] Run health check script
- [ ] Check all containers are running
- [ ] Review all screenshots
- [ ] Test on fresh Jenkins install

### During Demo
- [ ] Internet connection (if needed)
- [ ] Docker Desktop running
- [ ] Jenkins accessible
- [ ] Application accessible
- [ ] Screenshots accessible
- [ ] Commands ready

---

## 🔧 Troubleshooting Quick Reference

### Jenkins Won't Start
```powershell
cd jenkins
docker compose -f docker-compose.jenkins.yml down
docker compose -f docker-compose.jenkins.yml up -d --build
```

### Port Already in Use
```powershell
# Find and stop conflicting process
netstat -ano | findstr :3000
netstat -ano | findstr :8080
# Stop containers
docker stop jenkins-ci express-ci-demo
```

### Pipeline Fails at Tests
```powershell
# Manually run tests to debug
docker exec jenkins-ci bash -c "cd /var/jenkins_home/workspace/express-ci-demo && npm test"
```

### Application Not Responding
```powershell
# Check logs
docker logs express-ci-demo
# Restart container
docker restart express-ci-demo
```

### Cannot Access Docker in Jenkins
```powershell
# Restart Jenkins
docker restart jenkins-ci
# Or rebuild
cd jenkins
docker compose -f docker-compose.jenkins.yml down
docker compose -f docker-compose.jenkins.yml up -d --build
```

---

## 🧹 After Demo Cleanup

### Keep Everything Running
```powershell
# No action needed - containers will stay running
```

### Stop Application Only
```powershell
docker compose down
```

### Stop Everything (Keep Data)
```powershell
docker compose stop
cd jenkins
docker compose -f docker-compose.jenkins.yml stop
```

### Complete Cleanup
```powershell
# WARNING: This removes all data
docker compose down -v
cd jenkins
docker compose -f docker-compose.jenkins.yml down -v
docker rmi $(docker images -q express-ci-demo)
```

---

## ✅ Final Pre-Demo Checklist

### Technical
- [ ] All prerequisites installed
- [ ] Jenkins running and accessible
- [ ] Pipeline created and tested
- [ ] Application deployed and verified
- [ ] Screenshots captured
- [ ] Backup screenshots ready

### Documentation
- [ ] README.md reviewed
- [ ] Know how to access all docs
- [ ] Commands memorized or accessible
- [ ] Troubleshooting steps known

### Presentation
- [ ] Demo flow prepared
- [ ] Talking points ready
- [ ] Questions anticipated
- [ ] Backup plan ready

---

## 🎯 Success Criteria

✅ All items must be checked before demo:

- [ ] Jenkins is running in Docker
- [ ] Pipeline executes successfully
- [ ] All 7 stages complete
- [ ] Tests pass
- [ ] Docker image builds
- [ ] Application deploys
- [ ] Health check passes
- [ ] Application accessible at http://localhost:3000
- [ ] Health endpoint returns OK
- [ ] Screenshots captured
- [ ] Comfortable explaining each component

---

**When all items are checked, you're ready to demonstrate! 🚀**

**Good luck with your demo! 🎉**
