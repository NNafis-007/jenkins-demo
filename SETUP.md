# SETUP INSTRUCTIONS

## Complete Setup Guide for Jenkins CI/CD Pipeline

### Step 1: Start All Services

```bash
docker-compose up -d
```

Wait 30 seconds for Jenkins to initialize.

### Step 2: Setup Jenkins

#### Install Docker CLI in Jenkins
```bash
docker exec -u root jenkins-ci bash -c "apt-get update && apt-get install -y docker.io curl"
```

#### Install Node.js in Jenkins
```bash
docker exec -u root jenkins-ci bash -c "curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs"
```

#### Fix Docker Socket Permissions
```bash
docker exec -u root jenkins-ci chmod 666 /var/run/docker.sock
```

#### Verify Installations
```bash
docker exec jenkins-ci node --version
docker exec jenkins-ci npm --version
docker exec jenkins-ci docker --version
```

### Step 3: Copy Project to Jenkins Workspace

```bash
docker exec jenkins-ci mkdir -p /var/jenkins_home/workspace/express-ci-demo
docker cp app jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
docker cp Jenkinsfile jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
```

### Step 4: Create Pipeline Job in Jenkins

1. Open **http://localhost:8080**
2. Click **New Item**
3. Enter name: `express-ci-demo`
4. Select: **Pipeline**
5. Click **OK**
6. Scroll to **Pipeline** section
7. Definition: **Pipeline script**
8. Copy the entire content from `Jenkinsfile` and paste
9. Click **Save**

### Step 5: Run the Pipeline

1. Click **Build Now**
2. Click on build **#1**
3. Click **Console Output**
4. Watch all stages execute:
   - ✅ Build
   - ✅ Test
   - ✅ Package
   - ✅ Deploy
   - ✅ Health-Check

### Step 6: Verify Success

You should see:
```
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

### Step 7: Test the Application

```bash
# Test main endpoint
curl http://localhost:3000

# Test health endpoint
curl http://localhost:3000/health

# Run health check script
bash healthcheck.sh
```

## Screenshots Required

1. **Jenkins Dashboard** - showing successful build
2. **Console Output** - showing all stages completed
3. **Build → Deploy → Health OK** - visible in console

Save console output to `console-output.txt`:
```bash
# From Jenkins UI, copy console output and save
```

## Troubleshooting

**Problem: Permission denied on docker.sock**
```bash
docker exec -u root jenkins-ci chmod 666 /var/run/docker.sock
```

**Problem: npm not found**
```bash
# Reinstall Node.js
docker exec -u root jenkins-ci bash -c "curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs"
```

**Problem: Docker not found in Jenkins**
```bash
docker exec -u root jenkins-ci apt-get install -y docker.io
```

## Cleanup

```bash
# Stop all services
docker-compose down

# Remove everything including volumes
docker-compose down -v
docker rmi express-demo-app:latest
```
