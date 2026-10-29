@echo off
setlocal

REM ============================================================
REM UpperDev - AWS Training Project 2 UI Container Deployment
REM ============================================================

REM ============================================================
REM Step	Action
REM 1	Check Docker is running
REM 2	Build the Docker image
REM 3	Log in to Amazon ECR
REM 4	Tag and push the image to ECR
REM 5	Trigger ECS deployment and wait for stability
REM 6	Check ALB target health and test the UI
REM ============================================================


set "AWS_REGION=us-east-2"
set "AWS_ACCOUNT_ID=373078100695"
set "ECR_REPOSITORY=aws-training-project-2-ui"
set "ECR_REGISTRY=%AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com"
set "IMAGE_URI=%ECR_REGISTRY%/%ECR_REPOSITORY%:latest"
set "ECS_CLUSTER=aws-training-project-2-cluster"
set "ECS_SERVICE=aws-training-project-2-ui-service"
set "TARGET_GROUP_NAME=aws-training-project-2-ui-tg"
set "ALB_URL=http://aws-training-project-2-ui-alb-511214665.us-east-2.elb.amazonaws.com"

pushd "%~dp0"

echo.
echo [1/6] Checking Docker...
docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running. Start Docker Desktop and run this file again.
    goto :fail
)

echo.
echo [2/6] Building Docker image...
docker build -t %ECR_REPOSITORY%:latest .
if errorlevel 1 goto :fail

echo.
echo [3/6] Logging in to Amazon ECR...
aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %ECR_REGISTRY%
if errorlevel 1 (
    echo ERROR: ECR login failed. Check AWS CLI credentials and permissions.
    goto :fail
)

echo.
echo [4/6] Tagging and pushing image to ECR...
docker tag %ECR_REPOSITORY%:latest %IMAGE_URI%
if errorlevel 1 goto :fail

docker push %IMAGE_URI%
if errorlevel 1 goto :fail

echo.
echo [5/6] Triggering ECS deployment...
aws ecs update-service --cluster %ECS_CLUSTER% --service %ECS_SERVICE% --force-new-deployment --region %AWS_REGION%
if errorlevel 1 goto :fail

echo.
echo Waiting for ECS service to become stable. This may take a few minutes...
aws ecs wait services-stable --cluster %ECS_CLUSTER% --services %ECS_SERVICE% --region %AWS_REGION%
if errorlevel 1 (
    echo WARNING: ECS did not report a stable service. Check ECS service events and CloudWatch logs.
    goto :fail
)

echo.
echo [6/6] Checking ALB target health...
for /f "delims=" %%T in ('aws elbv2 describe-target-groups --names %TARGET_GROUP_NAME% --region %AWS_REGION% --query "TargetGroups[0].TargetGroupArn" --output text') do set "TARGET_GROUP_ARN=%%T"

if not defined TARGET_GROUP_ARN (
    echo ERROR: Could not find target group %TARGET_GROUP_NAME%.
    goto :fail
)

aws elbv2 describe-target-health --target-group-arn %TARGET_GROUP_ARN% --region %AWS_REGION% --query "TargetHealthDescriptions[*].{IP:Target.Id,Port:Target.Port,State:TargetHealth.State,Reason:TargetHealth.Reason}" --output table

echo.
echo Testing the application through the ALB...
curl.exe -I --max-time 15 %ALB_URL%

echo.
echo Deployment commands completed.
echo If the target is not healthy or the HTTP response is not successful, inspect ECS service events and CloudWatch logs.
echo UI URL: %ALB_URL%
popd
pause
exit /b 0

:fail
echo.
echo Deployment stopped because a command failed. Review the error above.
popd
pause
exit /b 1
