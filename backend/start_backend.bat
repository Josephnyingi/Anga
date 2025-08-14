@echo off
echo ========================================
echo    ANGA Backend Startup Script
echo ========================================
echo.

echo [1/5] Checking Python environment...
python --version
if %errorlevel% neq 0 (
    echo ❌ Python not found! Please install Python 3.8+
    pause
    exit /b 1
)
echo ✅ Python environment OK
echo.

echo [2/5] Initializing database...
python backend\init_db.py
if %errorlevel% neq 0 (
    echo ❌ Database initialization failed!
    pause
    exit /b 1
)
echo ✅ Database initialized successfully
echo.

echo [3/5] Running database tests...
python backend\database_test.py
if %errorlevel% neq 0 (
    echo ❌ Database tests failed!
    echo Continuing anyway, but please check the database setup...
    echo.
)
echo ✅ Database tests completed
echo.

echo [4/5] Starting FastAPI server...
echo 🚀 Server will be available at: http://localhost:8000
echo 📚 API Documentation: http://localhost:8000/docs
echo 🔍 Health Check: http://localhost:8000/health
echo.
echo Press Ctrl+C to stop the server
echo.

uvicorn backend.main_api:app --host 0.0.0.0 --port 8000 --reload
pause
