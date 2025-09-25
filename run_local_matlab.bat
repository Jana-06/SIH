@echo off
echo 🌾 Agricultural Monitoring Dashboard - Local Development with MATLAB
echo ==================================================================

REM Set environment for MATLAB integration  
set DEMO_MODE=0
set FLASK_DEBUG=1
set MATLAB_CMD=matlab

echo Environment configured for MATLAB integration:
echo - DEMO_MODE=0 (MATLAB analysis enabled)
echo - FLASK_DEBUG=1 (Debug mode enabled)  
echo - MATLAB_CMD=matlab (Default MATLAB command)
echo.

REM Check if MATLAB is available
matlab -batch "disp('MATLAB is available')" >nul 2>&1
if %ERRORLEVEL% == 0 (
    echo ✅ MATLAB found and working
) else (
    echo ⚠️  MATLAB not found or not working. Please ensure MATLAB is installed and accessible.
    echo    You can set custom MATLAB path with: set MATLAB_CMD=C:\path\to\matlab\bin\matlab.exe
)

echo.
echo 🚀 Starting Flask development server...
echo 📊 Your dashboard will be available at: http://localhost:5001  
echo 🧪 Click 'Run Analysis' to execute MATLAB analysis and generate real visualizations
echo.

REM Install requirements if needed 
pip install -r requirements.txt

REM Run Flask app with MATLAB integration
python app.py

pause