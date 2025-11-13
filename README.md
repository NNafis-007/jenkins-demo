# Jenkins CI/CD Pipeline Demo

Simple CI/CD pipeline demo with Jenkins running in Docker.

## Quick Start

### 1. Start Jenkins
```powershell
cd jenkins
docker compose -f docker-compose.jenkins.yml up -d
```

Wait 30 seconds for Jenkins to start, then open http://localhost:8080

**No password needed** - Setup wizard is disabled, Jenkins opens directly.

### 2. Install Node.js in Jenkins Container
```powershell
docker exec jenkins-ci bash -c "curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs"
```

### 3. Copy Project Files to Jenkins
```powershell
cd ..  # Go back to jenkins-demo folder
docker exec jenkins-ci mkdir -p /var/jenkins_home/workspace/express-ci-demo
docker cp app.js jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
docker cp package.json jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
docker cp tests jenkins-ci:/var/jenkins_home/workspace/express-ci-demo/
```

### 4. Create Pipeline Job in Jenkins
1. Open http://localhost:8080
2. Click **New Item** (or **Create a job**)
3. Name: `express-ci-demo`
4. Type: **Pipeline**
5. Click **OK**
6. Scroll down to **Pipeline** section
7. Definition: Select **Pipeline script**
8. Copy the entire content from `Jenkinsfile` and paste it
9. Click **Save**

### 5. Run Pipeline
1. Click **Build Now**
2. Click on the build number (e.g., #1) in Build History
3. Click **Console Output** to watch the pipeline run

You'll see all stages execute:
- ✅ Checkout
- ✅ Install Dependencies
- ✅ Unit Tests
- ✅ Build Application
- ✅ Deploy
- ✅ Health Check
- ✅ Display Status

### 6. View Application
The app runs inside Jenkins container. To test it:

```powershell
# From inside Jenkins container
docker exec jenkins-ci curl http://localhost:3000
docker exec jenkins-ci curl http://localhost:3000/health
```

You should see:
- Main endpoint: "Hello World from CI/CD demo!"
- Health endpoint: `{"status":"ok"}`

## View Pipeline Output

After running the pipeline, you can:

1. **Console Output** - Click build #1 → Console Output
   - See detailed logs of each stage
   - See test results
   - See deployment confirmation

2. **Blue Ocean** (Better Visualization)
   - Click "Open Blue Ocean" in sidebar
   - See visual pipeline with all stages
   - Green checkmarks for success

## Pipeline Stages

1. **Checkout** - Verify workspace
2. **Install Dependencies** - Run `npm install`
3. **Unit Tests** - Run `npm test` (2 tests pass)
4. **Build Application** - Prepare app
5. **Deploy** - Start the app on port 3000
6. **Health Check** - Verify `/health` endpoint
7. **Display Status** - Show deployment info

## Cleanup

```powershell
# Stop Jenkins
cd jenkins
docker compose -f docker-compose.jenkins.yml down

# Remove all data
docker compose -f docker-compose.jenkins.yml down -v
```

## Troubleshooting

**Jenkins not accessible:**
```powershell
docker logs jenkins-ci
# Wait until you see "Jenkins is fully up and running"
```

**Pipeline fails at tests:**
```powershell
# Verify Node.js is installed
docker exec jenkins-ci node --version
docker exec jenkins-ci npm --version
```

**See app logs:**
```powershell
docker exec jenkins-ci cat /var/jenkins_home/workspace/express-ci-demo/app.log
```
