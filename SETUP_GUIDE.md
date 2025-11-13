# 🚀 Quick Setup & Execution Guide

## Step-by-Step Instructions to Run the Complete CI/CD Pipeline

### Prerequisites Check
```powershell
# Verify Docker is running
docker --version
docker ps

# Verify Docker Compose
docker compose version
```

---

## 🎯 Part 1: Start Jenkins (Docker-in-Docker)

### 1. Navigate to Jenkins Directory
```powershell
cd jenkins
```

### 2. Build and Start Jenkins Container
```powershell
# Build custom Jenkins image with Docker support
docker compose -f docker-compose.jenkins.yml up -d --build

# Verify Jenkins is running
docker ps
```

Expected output: You should see `jenkins-ci` container running on ports 8080 and 50000

### 3. Access Jenkins Web UI

Open your browser and go to: **http://localhost:8080**

### 4. Get Initial Admin Password
```powershell
# Copy this password
docker exec jenkins-ci cat /var/jenkins_home/secrets/initialAdminPassword
```

### 5. Complete Jenkins Setup Wizard
1. Paste the admin password
2. Click **Install suggested plugins** (wait for installation to complete)
3. Create First Admin User:
   - Username: `admin`
   - Password: `admin` (or your choice)
   - Full name: `Admin User`
   - Email: `admin@example.com`
4. Keep the default Jenkins URL: `http://localhost:8080/`
5. Click **Start using Jenkins**

---

## 🔧 Part 2: Create Jenkins Pipeline Job

### 1. Create New Pipeline Job
1. Click **New Item** (or **Create a job**)
2. Enter item name: `express-ci-demo`
3. Select **Pipeline**
4. Click **OK**

### 2. Configure the Pipeline

#### General Section:
- Description: `CI/CD Pipeline for Express Demo App`

#### Pipeline Section:
- Definition: Select **Pipeline script from SCM**
- SCM: Select **Git**
- Repository URL: 
  ```
  file:///var/jenkins_home/workspace/project
  ```
  **OR** if you have the code in Jenkins workspace already, use **Pipeline script** and paste the Jenkinsfile content.

**EASIER METHOD: Use Pipeline Script Directly**
1. Definition: Select **Pipeline script**
2. Copy the entire content from `Jenkinsfile` and paste it in the Script box
3. **IMPORTANT**: Before saving, modify the checkout stage:

Replace:
```groovy
stage('Checkout') {
    steps {
        echo '=== Stage: Checkout ==='
        checkout scm
        echo 'Source code checked out successfully'
    }
}
```

With:
```groovy
stage('Checkout') {
    steps {
        echo '=== Stage: Checkout ==='
        // For demonstration, we'll work with files in the workspace
        sh 'pwd && ls -la'
        echo 'Working directory verified'
    }
}
```

4. Click **Save**

### 3. Copy Project Files to Jenkins Container

From your project root directory (jenkins-demo):

```powershell
# Go back to project root
cd ..

# Copy project files to Jenkins workspace
docker cp app.js jenkins-ci:/tmp/
docker cp package.json jenkins-ci:/tmp/
docker cp Dockerfile jenkins-ci:/tmp/
docker cp docker-compose.yml jenkins-ci:/tmp/
docker cp healthcheck.sh jenkins-ci:/tmp/
docker cp tests jenkins-ci:/tmp/

# Create workspace directory and move files
docker exec jenkins-ci mkdir -p /var/jenkins_home/workspace/express-ci-demo
docker exec jenkins-ci cp -r /tmp/app.js /tmp/package.json /tmp/Dockerfile /tmp/docker-compose.yml /tmp/healthcheck.sh /tmp/tests /var/jenkins_home/workspace/express-ci-demo/
```

**Alternative Method (Recommended):**
Modify the Pipeline to checkout from your actual Git repository:
1. Push your code to GitHub/GitLab
2. In Pipeline configuration, use your repository URL
3. Jenkins will automatically clone it

---

## ▶️ Part 3: Run the Pipeline

### 1. Start the Build
1. Go to your pipeline job: `express-ci-demo`
2. Click **Build Now** (left sidebar)

### 2. Monitor the Build
- Watch the build progress in the **Build History** (left sidebar)
- Click on the build number (e.g., `#1`) to see details
- Click **Console Output** to see real-time logs

### 3. View Blue Ocean (Better Visualization)
1. Click **Open Blue Ocean** (left sidebar)
2. You'll see a visual pipeline with all stages
3. This view is perfect for screenshots!

---

## 📸 Part 4: Capture Required Screenshots

### Screenshot 1: Jenkins Dashboard
- Navigate to: `http://localhost:8080`
- Show the successful build with green checkmark
- **Capture**: Full Jenkins dashboard

### Screenshot 2: Blue Ocean Pipeline View
- Click **Open Blue Ocean**
- Show all stages in green (success)
- **Capture**: Full pipeline stages view

### Screenshot 3: Console Output - Part 1
- Click on build `#1`
- Click **Console Output**
- Scroll to show:
  - Checkout stage
  - Install Dependencies stage
  - **Capture**: These initial stages

### Screenshot 4: Console Output - Part 2
- Continue scrolling in Console Output
- **Capture**: 
  - Unit Tests stage output showing "All tests passed"
  - Build Docker Image stage

### Screenshot 5: Console Output - Part 3
- Continue scrolling
- **Capture**:
  - Deploy stage
  - Health Check stage with "✓ HEALTH CHECK PASSED"

### Screenshot 6: Console Output - Final Summary
- Scroll to the bottom
- **Capture**: 
  - Application Status display
  - Final "PIPELINE SUCCESS" message
  - Application URL confirmation

### Screenshot 7: Application in Browser
Open new browser tab:
```
http://localhost:3000
```
**Capture**: "Hello World from CI/CD demo!" message

### Screenshot 8: Health Endpoint
Open new browser tab:
```
http://localhost:3000/health
```
**Capture**: `{"status":"ok"}` JSON response

### Screenshot 9: Docker Containers Running
In PowerShell:
```powershell
docker ps
```
**Capture**: Output showing both `jenkins-ci` and `express-ci-demo` containers running

### Screenshot 10: Health Check Script Output
```powershell
# Make script executable (in Git Bash or WSL)
bash healthcheck.sh

# Or run via Docker
docker exec jenkins-ci bash /var/jenkins_home/workspace/express-ci-demo/healthcheck.sh
```
**Capture**: Complete health check output with "✓ HEALTH CHECK PASSED"

---

## 🧪 Part 5: Verify Everything Works

### Test the Application
```powershell
# Test main endpoint
curl http://localhost:3000

# Test health endpoint
curl http://localhost:3000/health

# Check container status
docker ps | findstr express-ci-demo

# View application logs
docker logs express-ci-demo

# Run manual health check
docker exec jenkins-ci bash -c "cd /var/jenkins_home/workspace/express-ci-demo && ./healthcheck.sh"
```

---

## 🎓 Part 6: Understanding the Pipeline

### Pipeline Stages Explained:

1. **Checkout** ✅
   - Gets the source code
   - Verifies workspace

2. **Install Dependencies** ✅
   - Runs `npm install` in Docker container
   - Installs all Node.js packages

3. **Unit Tests** ✅
   - Runs `npm test` (Jest tests)
   - Validates app functionality
   - **Must pass to continue**

4. **Build Docker Image** ✅
   - Creates Docker image: `express-ci-demo:jenkins-{BUILD_NUMBER}`
   - Includes app + dependencies

5. **Package & Deploy** ✅
   - Uses Docker Compose
   - Starts container on port 3000

6. **Health Check** ✅
   - Runs healthcheck.sh script
   - Verifies container is healthy
   - Tests /health endpoint

7. **Display Application Status** ✅
   - Shows deployment summary
   - Displays container info
   - Confirms success

---

## 🔄 Part 7: Run Pipeline Again (Demonstrate CI/CD)

### Modify Code and Re-run
```powershell
# Edit app.js to change the message
# Then copy updated file to Jenkins
docker cp app.js jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/

# In Jenkins UI, click "Build Now" again
# Watch it run through all stages again
# New build number will increment
```

---

## 🧹 Part 8: Cleanup (When Done)

### Stop the Application
```powershell
docker compose down
```

### Stop Jenkins (Keep Data)
```powershell
cd jenkins
docker compose -f docker-compose.jenkins.yml stop
```

### Complete Cleanup (Remove Everything)
```powershell
# Remove application containers
docker compose down -v

# Remove Jenkins (WARNING: Deletes all Jenkins data)
cd jenkins
docker compose -f docker-compose.jenkins.yml down -v

# Remove Docker images
docker rmi express-ci-demo:latest
docker rmi $(docker images -q express-ci-demo:jenkins-*)
```

---

## ❓ Troubleshooting During Demo

### Issue: "Cannot connect to Docker daemon"
```powershell
# Restart Jenkins with proper permissions
cd jenkins
docker compose -f docker-compose.jenkins.yml down
docker compose -f docker-compose.jenkins.yml up -d
```

### Issue: Port 3000 already in use
```powershell
# Find and stop conflicting container
docker ps -a | findstr 3000
docker stop <container-name>
docker rm <container-name>
```

### Issue: Tests failing
```powershell
# Check if dependencies were installed
docker exec jenkins-ci ls -la /var/jenkins_home/workspace/express-ci-demo/node_modules/

# Manually run tests
docker exec jenkins-ci bash -c "cd /var/jenkins_home/workspace/express-ci-demo && npm test"
```

### Issue: Health check timeout
```powershell
# Check if app is running
docker logs express-ci-demo

# Test health endpoint manually
curl http://localhost:3000/health

# Check container health status
docker inspect express-ci-demo | findstr Health
```

---

## 📋 Pre-Demo Checklist

- [ ] Docker Desktop is running
- [ ] Ports 8080 and 3000 are available
- [ ] Project files are ready
- [ ] Jenkins is started and accessible at http://localhost:8080
- [ ] Jenkins setup wizard completed
- [ ] Pipeline job created
- [ ] Project files copied to Jenkins workspace
- [ ] Ready to click "Build Now"

---

## 🎬 Demo Script (What to Say)

1. **"I've set up Jenkins running in Docker using Docker-in-Docker"**
   - Show jenkins/Dockerfile and docker-compose.jenkins.yml

2. **"This is the Jenkinsfile - a declarative pipeline with 7 stages"**
   - Walk through Jenkinsfile stages

3. **"Let me trigger the pipeline"**
   - Click Build Now
   - Show Blue Ocean view

4. **"As you can see, it's running through each stage:"**
   - Point out each stage as it executes
   - Show green checkmarks

5. **"Here's the console output showing the test results"**
   - Scroll through console output

6. **"The health check confirms the application is running"**
   - Show health check success in logs

7. **"And here's the application running"**
   - Open http://localhost:3000 in browser
   - Show health endpoint

8. **"The entire process is automated - from code to deployment"**
   - Summarize what was accomplished

---

**You're all set! Run through this guide and capture the screenshots. Good luck with your demo! 🚀**
