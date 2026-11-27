@echo off
setlocal
title HEIC to JPG (Python)

echo ==========================================
echo        HEIC TO JPG - PYTHON VERSION
echo ==========================================
echo.

:: Script folder (the folder this .bat lives in)
set "SCRIPT_DIR=%~dp0"
set "SCRIPT=%SCRIPT_DIR%convert_HEIC_to_JPG.py"

:: Use the folder this .bat lives in as the input folder,
:: and put the JPGs in a "JPG" folder inside it
for %%I in ("%~dp0.") do set "INPUT_DIR=%%~fI"
for %%I in ("%~dp0JPG") do set "OUTPUT_DIR=%%~fI"

if not exist "%SCRIPT%" (
    echo ERROR: convert_HEIC_to_JPG.py not found in:
    echo %SCRIPT_DIR%
    echo.
    pause
    exit /b 1
)

:: Check for Python
where python >nul 2>nul
if errorlevel 1 (
    where py >nul 2>nul
    if errorlevel 1 (
        echo ERROR: Python is not found in PATH.
        pause
        exit /b 1
    )
    set "PYTHON=py"
) else (
    set "PYTHON=python"
)

echo Input folder:
echo %INPUT_DIR%
echo Output folder:
echo %OUTPUT_DIR%
echo.

%PYTHON% "%SCRIPT%" "%INPUT_DIR%" "%OUTPUT_DIR%"

if errorlevel 1 (
    echo.
    echo Something went wrong. See the messages above.
    pause
    exit /b 1
)

echo.
echo Done!
pause
