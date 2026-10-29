@echo off
setlocal

cd /d "%~dp0"

set "IMAGE_NAME=aws-training-project-2-ui"
set "CONTAINER_NAME=aws-training-project-2-ui"
set "HOST_PORT=3001"
set "CONTAINER_PORT=3000"

echo.
echo ==========================================
echo   Dockerize and run Next.js UI
echo ==========================================
echo.

where docker >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker was not found. Install/start Docker Desktop and try again.
    pause
    exit /b 1
)

echo [1/3] Building Docker image: %IMAGE_NAME%
docker build -t "%IMAGE_NAME%" .
if errorlevel 1 (
    echo.
    echo ERROR: Docker image build failed. Existing container was not replaced.
    pause
    exit /b 1
)

echo.
echo [2/3] Removing previous container, if present...
docker rm -f "%CONTAINER_NAME%" >nul 2>&1

echo.
echo [3/3] Starting container on http://localhost:%HOST_PORT%
docker run -d --name "%CONTAINER_NAME%" -p %HOST_PORT%:%CONTAINER_PORT% "%IMAGE_NAME%"
if errorlevel 1 (
    echo.
    echo ERROR: Container failed to start.
    echo Check whether port %HOST_PORT% is already in use.
    pause
    exit /b 1
)

echo.
echo SUCCESS: UI is running at http://localhost:%HOST_PORT%
echo.
echo Useful commands:
echo   View logs:  docker logs -f %CONTAINER_NAME%
echo   Stop:       docker stop %CONTAINER_NAME%
echo   Restart:    docker start %CONTAINER_NAME%
echo.
pause
endlocal
