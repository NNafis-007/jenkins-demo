# Jenkins CI/CD Pipeline Setup Script for Windows PowerShell
# This script helps you set up and run the complete CI/CD pipeline

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Jenkins CI/CD Pipeline Setup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Function to check prerequisites
function Check-Prerequisites {
    Write-Host "Checking prerequisites..." -ForegroundColor Yellow
    
    # Check Docker
    try {
        $dockerVersion = docker --version
        Write-Host "✓ Docker installed: $dockerVersion" -ForegroundColor Green
    } catch {
        Write-Host "✗ Docker not found! Please install Docker Desktop." -ForegroundColor Red
        exit 1
    }
    
    # Check Docker is running
    try {
        docker ps | Out-Null
        Write-Host "✓ Docker is running" -ForegroundColor Green
    } catch {
        Write-Host "✗ Docker is not running! Please start Docker Desktop." -ForegroundColor Red
        exit 1
    }
    
    # Check Docker Compose
    try {
        $composeVersion = docker compose version
        Write-Host "✓ Docker Compose installed: $composeVersion" -ForegroundColor Green
    } catch {
        Write-Host "✗ Docker Compose not found!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
}

# Function to start Jenkins
function Start-Jenkins {
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Starting Jenkins..." -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    
    Push-Location jenkins
    
    # Build and start Jenkins
    Write-Host "Building Jenkins with Docker support..." -ForegroundColor Yellow
    docker compose -f docker-compose.jenkins.yml up -d --build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Jenkins started successfully!" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to start Jenkins" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    
    Pop-Location
    Write-Host ""
    
    # Wait for Jenkins to be ready
    Write-Host "Waiting for Jenkins to be ready..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    # Get initial admin password
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "Jenkins Initial Admin Password:" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    try {
        $password = docker exec jenkins-ci cat /var/jenkins_home/secrets/initialAdminPassword
        Write-Host $password -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Save this password! You'll need it to log in." -ForegroundColor Cyan
    } catch {
        Write-Host "Could not retrieve password yet. Jenkins might still be starting..." -ForegroundColor Yellow
        Write-Host "Run this command in a few seconds:" -ForegroundColor Cyan
        Write-Host "docker exec jenkins-ci cat /var/jenkins_home/secrets/initialAdminPassword" -ForegroundColor White
    }
    Write-Host ""
    
    # Display access information
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "Jenkins Access Information" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "URL: http://localhost:8080" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Open http://localhost:8080 in your browser" -ForegroundColor White
    Write-Host "2. Enter the admin password shown above" -ForegroundColor White
    Write-Host "3. Install suggested plugins" -ForegroundColor White
    Write-Host "4. Create your admin user" -ForegroundColor White
    Write-Host "5. Run 'setup-jenkins-job' command to create the pipeline" -ForegroundColor White
    Write-Host ""
}

# Function to copy project files to Jenkins
function Copy-ProjectFiles {
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Copying project files to Jenkins..." -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    
    # Create temp directory in container
    docker exec jenkins-ci mkdir -p /tmp/project
    
    # Copy files
    docker cp app.js jenkins-ci:/tmp/project/
    docker cp package.json jenkins-ci:/tmp/project/
    docker cp Dockerfile jenkins-ci:/tmp/project/
    docker cp docker-compose.yml jenkins-ci:/tmp/project/
    docker cp healthcheck.sh jenkins-ci:/tmp/project/
    docker cp tests jenkins-ci:/tmp/project/
    
    # Create workspace directory
    docker exec jenkins-ci mkdir -p /var/jenkins_home/workspace/express-ci-demo
    
    # Move files to workspace
    docker exec jenkins-ci cp -r /tmp/project/. /var/jenkins_home/workspace/express-ci-demo/
    
    # Make healthcheck.sh executable
    docker exec jenkins-ci chmod +x /var/jenkins_home/workspace/express-ci-demo/healthcheck.sh
    
    Write-Host "✓ Project files copied successfully!" -ForegroundColor Green
    Write-Host ""
}

# Function to display Jenkins job creation instructions
function Show-JobInstructions {
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Create Jenkins Pipeline Job" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Follow these steps in Jenkins UI:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Click 'New Item'" -ForegroundColor White
    Write-Host "2. Enter name: express-ci-demo" -ForegroundColor White
    Write-Host "3. Select 'Pipeline' and click OK" -ForegroundColor White
    Write-Host "4. In Pipeline section:" -ForegroundColor White
    Write-Host "   - Definition: Pipeline script" -ForegroundColor White
    Write-Host "   - Copy content from Jenkinsfile and paste" -ForegroundColor White
    Write-Host "5. Click 'Save'" -ForegroundColor White
    Write-Host "6. Click 'Build Now'" -ForegroundColor White
    Write-Host ""
}

# Function to check application status
function Check-Application {
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Checking Application Status..." -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    
    # Check if container is running
    $container = docker ps --filter "name=express-ci-demo" --format "{{.Names}}"
    
    if ($container -eq "express-ci-demo") {
        Write-Host "✓ Application container is running" -ForegroundColor Green
        
        # Test health endpoint
        try {
            $response = Invoke-RestMethod -Uri "http://localhost:3000/health" -ErrorAction Stop
            Write-Host "✓ Health endpoint responded: status = $($response.status)" -ForegroundColor Green
        } catch {
            Write-Host "✗ Health endpoint not responding yet" -ForegroundColor Yellow
        }
        
        # Test main endpoint
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:3000" -ErrorAction Stop
            Write-Host "✓ Main endpoint responding" -ForegroundColor Green
        } catch {
            Write-Host "✗ Main endpoint not responding yet" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "Access your application at:" -ForegroundColor Cyan
        Write-Host "http://localhost:3000" -ForegroundColor White
        Write-Host "http://localhost:3000/health" -ForegroundColor White
        
    } else {
        Write-Host "✗ Application container is not running" -ForegroundColor Red
        Write-Host "Run the Jenkins pipeline to deploy it" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Function to show running containers
function Show-Containers {
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Running Containers" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    Write-Host ""
}

# Function to cleanup
function Cleanup-All {
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Cleaning Up..." -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    
    $confirm = Read-Host "This will stop and remove all containers. Continue? (y/N)"
    
    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        # Stop application
        docker compose down
        
        # Stop Jenkins
        Push-Location jenkins
        docker compose -f docker-compose.jenkins.yml down
        Pop-Location
        
        Write-Host "✓ Cleanup completed" -ForegroundColor Green
    } else {
        Write-Host "Cleanup cancelled" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Main menu
function Show-Menu {
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Jenkins CI/CD Pipeline - Main Menu" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Check Prerequisites" -ForegroundColor White
    Write-Host "2. Start Jenkins" -ForegroundColor White
    Write-Host "3. Copy Project Files to Jenkins" -ForegroundColor White
    Write-Host "4. Show Job Creation Instructions" -ForegroundColor White
    Write-Host "5. Check Application Status" -ForegroundColor White
    Write-Host "6. Show Running Containers" -ForegroundColor White
    Write-Host "7. View Jenkins Logs" -ForegroundColor White
    Write-Host "8. View Application Logs" -ForegroundColor White
    Write-Host "9. Cleanup All" -ForegroundColor White
    Write-Host "0. Exit" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Enter your choice"
    
    switch ($choice) {
        "1" { Check-Prerequisites; Pause; Show-Menu }
        "2" { Check-Prerequisites; Start-Jenkins; Pause; Show-Menu }
        "3" { Copy-ProjectFiles; Pause; Show-Menu }
        "4" { Show-JobInstructions; Pause; Show-Menu }
        "5" { Check-Application; Pause; Show-Menu }
        "6" { Show-Containers; Pause; Show-Menu }
        "7" { docker logs jenkins-ci --tail 50; Pause; Show-Menu }
        "8" { docker logs express-ci-demo --tail 50; Pause; Show-Menu }
        "9" { Cleanup-All; Pause; Show-Menu }
        "0" { Write-Host "Goodbye!" -ForegroundColor Green; exit 0 }
        default { Write-Host "Invalid choice!" -ForegroundColor Red; Pause; Show-Menu }
    }
}

# Start the menu
Show-Menu
