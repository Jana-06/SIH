@echo off
echo Testing MATLAB Agricultural Monitoring System
echo.

REM Try to find MATLAB installation
set MATLAB_PATH=""
if exist "C:\Program Files\MATLAB\R2024a\bin\matlab.exe" set MATLAB_PATH="C:\Program Files\MATLAB\R2024a\bin\matlab.exe"
if exist "C:\Program Files\MATLAB\R2023b\bin\matlab.exe" set MATLAB_PATH="C:\Program Files\MATLAB\R2023b\bin\matlab.exe"
if exist "C:\Program Files\MATLAB\R2023a\bin\matlab.exe" set MATLAB_PATH="C:\Program Files\MATLAB\R2023a\bin\matlab.exe"
if exist "C:\Program Files\MATLAB\R2022b\bin\matlab.exe" set MATLAB_PATH="C:\Program Files\MATLAB\R2022b\bin\matlab.exe"
if exist "C:\Program Files\MATLAB\R2022a\bin\matlab.exe" set MATLAB_PATH="C:\Program Files\MATLAB\R2022a\bin\matlab.exe"
if exist "C:\Program Files\MATLAB\R2021b\bin\matlab.exe" set MATLAB_PATH="C:\Program Files\MATLAB\R2021b\bin\matlab.exe"
if exist "C:\Program Files\MATLAB\R2021a\bin\matlab.exe" set MATLAB_PATH="C:\Program Files\MATLAB\R2021a\bin\matlab.exe"
if exist "C:\Program Files\MATLAB\R2020b\bin\matlab.exe" set MATLAB_PATH="C:\Program Files\MATLAB\R2020b\bin\matlab.exe"
if exist "C:\Program Files\MATLAB\R2020a\bin\matlab.exe" set MATLAB_PATH="C:\Program Files\MATLAB\R2020a\bin\matlab.exe"
if exist "C:\Program Files\MATLAB\R2019b\bin\matlab.exe" set MATLAB_PATH="C:\Program Files\MATLAB\R2019b\bin\matlab.exe"

if %MATLAB_PATH%=="" (
    echo MATLAB not found in standard locations.
    echo Please ensure MATLAB is installed and in your PATH.
    echo.
    echo You can manually run the following in MATLAB:
    echo   cd %CD%
    echo   run('test_system.m')
    echo   run('examples/training_and_inference_demo.m')
    pause
    exit /b 1
)

echo Found MATLAB at: %MATLAB_PATH%
echo Running system test...
echo.

%MATLAB_PATH% -batch "cd('%CD%'); run('test_system.m')"

echo.
echo Test completed. Press any key to continue...
pause
