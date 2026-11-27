@echo off
setlocal EnableExtensions
title PNG / JPG / PDF Compressor

rem ============================================================
rem  Put this .bat in a folder with photos/documents, or in a
rem  folder that contains subfolders with photos/documents.
rem  It processes this folder AND all subfolders.
rem
rem  One "Compressed" folder is created in the top folder, and the
rem  subfolder structure is mirrored inside it. Originals are NOT changed.
rem ============================================================

rem ---------------- settings ----------------
rem  These JPG settings match the classic ACDSee 5.0 workflow:
rem    quality 75, 4:2:0 colour sampling, metadata removed.
rem  JPG_QUALITY: 70 = smaller, 75 = ACDSee default, 85 = better quality
set "JPG_QUALITY=75"
rem  JPG_PROGRESSIVE: 1 = about 5%% smaller, same quality, but some old
rem  printers/CAD viewers cannot open progressive JPGs. 0 = safest.
set "JPG_PROGRESSIVE=0"
rem  MAX_SIDE: longest side in pixels. 0 = keep original size.
rem  ACDSee 5.0 batch convert shrinks images to roughly 3000-4000 px,
rem  which is why its files come out about 10x smaller.
rem  Set 4000 to copy ACDSee, or 2560 for even smaller files.
set "MAX_SIDE=4000"
set "PNG_LEVEL=9"
set "PDF_PROFILE=/ebook"
rem   /screen  = smallest, 72 dpi
rem   /ebook   = good balance, 150 dpi  (default)
rem   /printer = high quality, 300 dpi
rem ------------------------------------------
rem  Build the optional resize argument ("1600x1600>" only shrinks).
set "RS="
if not "%MAX_SIDE%"=="0" set RS=-resize "%MAX_SIDE%x%MAX_SIDE%>"

set "ROOT=%~dp0"
set "OUTROOT=%ROOT%Compressed"

echo ==========================================
echo        PNG / JPG / PDF COMPRESSOR
echo ==========================================
echo.
echo Input folder:
echo   %ROOT%
echo.
echo This folder and all its subfolders will be processed.
echo All results go into:
echo   %OUTROOT%
echo Subfolders are mirrored inside it.
echo.

rem ---------- find ImageMagick ----------
set "MAGICK="
magick -version >nul 2>nul
if not errorlevel 1 set "MAGICK=magick"
if not defined MAGICK (
    for /d %%D in ("%ProgramFiles%\ImageMagick-*") do (
        if exist "%%~fD\magick.exe" set "MAGICK=%%~fD\magick.exe"
    )
)
if not defined MAGICK (
    echo ERROR: ImageMagick was not found.
    echo Install it from https://imagemagick.org/script/download.php
    echo During installation, enable "Add to PATH".
    echo.
    pause
    exit /b 1
)

rem ---------- find Ghostscript ----------
set "GS="
gswin64c.exe --version >nul 2>nul
if not errorlevel 1 set "GS=gswin64c.exe"
if not defined GS (
    gswin32c.exe --version >nul 2>nul
    if not errorlevel 1 set "GS=gswin32c.exe"
)
if not defined GS (
    for /d %%G in ("%ProgramFiles%\gs\gs*") do (
        if exist "%%~fG\bin\gswin64c.exe" set "GS=%%~fG\bin\gswin64c.exe"
        if exist "%%~fG\bin\gswin32c.exe" set "GS=%%~fG\bin\gswin32c.exe"
    )
)
if not defined GS (
    echo WARNING: Ghostscript was not found. PDF files will be skipped.
    echo Install it from https://www.ghostscript.com/releases/gsdnld.html
    echo.
)

set /a JPG_OK=0, JPG_FAIL=0
set /a PNG_OK=0, PNG_FAIL=0
set /a PDF_OK=0, PDF_FAIL=0
set /a TOTAL_IN_KB=0, TOTAL_OUT_KB=0

call :PROCESS_DIR "%ROOT%" "%OUTROOT%"

echo.
echo ==========================================
echo                 FINISHED
echo ==========================================
echo JPG/JPEG: %JPG_OK% compressed, %JPG_FAIL% failed
echo PNG:      %PNG_OK% compressed, %PNG_FAIL% failed
echo PDF:      %PDF_OK% compressed, %PDF_FAIL% failed
echo.

set /a TOTAL_OK=%JPG_OK%+%PNG_OK%+%PDF_OK%
set /a TOTAL_FAIL=%JPG_FAIL%+%PNG_FAIL%+%PDF_FAIL%
if %TOTAL_OK% EQU 0 goto :SHOW_RESULTS
if %TOTAL_IN_KB% LEQ 0 goto :SHOW_RESULTS
set /a SAVE_TOTAL_KB=%TOTAL_IN_KB%-%TOTAL_OUT_KB%
set /a SAVE_TOTAL_PCT=(%TOTAL_IN_KB%-%TOTAL_OUT_KB%)*100/%TOTAL_IN_KB%
echo Total: %TOTAL_IN_KB% KB -^> %TOTAL_OUT_KB% KB
echo Saved: %SAVE_TOTAL_KB% KB ^(%SAVE_TOTAL_PCT%%%^)
echo.

:SHOW_RESULTS
if %TOTAL_OK% EQU 0 if %TOTAL_FAIL% EQU 0 (
    echo No JPG, PNG, or PDF files were found in this folder or its subfolders.
    echo.
)
echo Results folder:
echo   %OUTROOT%
echo.
pause
exit /b

rem ============================================================
rem  Process one folder, then recurse into its subfolders
rem ============================================================
:PROCESS_DIR
for %%A in ("%~1.") do set "DIR=%%~fA"
for %%O in ("%~2.") do set "OUT=%%~fO"

rem ---------- any supported files in this folder? ----------
set "ANY="
for %%F in ("%DIR%\*.jpg" "%DIR%\*.jpeg" "%DIR%\*.jpe" "%DIR%\*.jfif" "%DIR%\*.png" "%DIR%\*.pdf") do (
    if exist "%%~fF" set "ANY=1"
)
if not defined ANY goto :PROCESS_SUBDIRS

echo.
echo ==========================================
echo Folder: "%DIR%"
echo Output: "%OUT%"
echo ==========================================
if not exist "%OUT%" mkdir "%OUT%"

echo [1/3] Compressing JPG / JPEG...
for %%F in ("%DIR%\*.jpg" "%DIR%\*.jpeg" "%DIR%\*.jpe" "%DIR%\*.jfif") do (
    if exist "%%~fF" call :DO_JPG "%%~fF"
)

echo.
echo [2/3] Compressing PNG...
for %%F in ("%DIR%\*.png") do (
    if exist "%%~fF" call :DO_PNG "%%~fF"
)

echo.
echo [3/3] Compressing PDF...
if defined GS (
    for %%F in ("%DIR%\*.pdf") do (
        if exist "%%~fF" call :DO_PDF "%%~fF"
    )
) else (
    echo PDF compression skipped - Ghostscript is not installed.
)

:PROCESS_SUBDIRS
for /d %%S in ("%DIR%\*") do (
    if /i not "%%~nxS"=="Compressed" call :PROCESS_DIR "%%~fS" "%OUT%\%%~nxS"
)
exit /b

rem ============================================================
rem  JPG / JPEG
rem ============================================================
:DO_JPG
echo Processing: "%~nx1"
set "DST=%OUT%\%~n1.jpg"
del /q "%DST%" >nul 2>nul
if "%JPG_PROGRESSIVE%"=="1" (
    %MAGICK% "%~1" -auto-orient -strip %RS% -quality %JPG_QUALITY% -sampling-factor 4:2:0 -define jpeg:optimize-coding=true -interlace Plane "%DST%" 2>nul
) else (
    %MAGICK% "%~1" -auto-orient -strip %RS% -quality %JPG_QUALITY% -sampling-factor 4:2:0 -define jpeg:optimize-coding=true "%DST%" 2>nul
)
if errorlevel 1 goto :FAIL_JPG
call :KEEP_SMALLER "%~1" "%DST%"
if errorlevel 1 goto :FAIL_JPG
set /a JPG_OK+=1
exit /b

:FAIL_JPG
echo   FAILED
del /q "%DST%" >nul 2>nul
set /a JPG_FAIL+=1
exit /b

rem ============================================================
rem  PNG
rem ============================================================
:DO_PNG
echo Processing: "%~nx1"
set "DST=%OUT%\%~n1.png"
del /q "%DST%" >nul 2>nul
%MAGICK% "%~1" -strip %RS% -define png:compression-level=%PNG_LEVEL% -define png:compression-filter=5 -define png:compression-strategy=1 "%DST%" 2>nul
if errorlevel 1 goto :FAIL_PNG
call :KEEP_SMALLER "%~1" "%DST%"
if errorlevel 1 goto :FAIL_PNG
set /a PNG_OK+=1
exit /b

:FAIL_PNG
echo   FAILED
del /q "%DST%" >nul 2>nul
set /a PNG_FAIL+=1
exit /b

rem ============================================================
rem  PDF
rem ============================================================
:DO_PDF
echo Processing: "%~nx1"
set "DST=%OUT%\%~n1.pdf"
del /q "%DST%" >nul 2>nul
"%GS%" -dSAFER -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dCompatibilityLevel=1.6 -dPDFSETTINGS=%PDF_PROFILE% -dDetectDuplicateImages=true -dCompressFonts=true -dSubsetFonts=true -sOutputFile="%DST%" "%~1" >nul 2>nul
if errorlevel 1 goto :FAIL_PDF
call :KEEP_SMALLER "%~1" "%DST%"
if errorlevel 1 goto :FAIL_PDF
set /a PDF_OK+=1
exit /b

:FAIL_PDF
echo   FAILED
del /q "%DST%" >nul 2>nul
set /a PDF_FAIL+=1
exit /b

rem ============================================================
rem  Keep the original if the "compressed" file is not smaller
rem ============================================================
:KEEP_SMALLER
if not exist "%~2" exit /b 1
for %%A in ("%~1") do set "SZ_IN=%%~zA"
for %%B in ("%~2") do set "SZ_OUT=%%~zB"
if %SZ_OUT% GEQ %SZ_IN% (
    copy /y "%~1" "%~2" >nul
    for %%B in ("%~2") do set "SZ_OUT=%%~zB"
    echo   Not smaller - kept the original.
)
set /a SZ_IN_KB=%SZ_IN%/1024
set /a SZ_OUT_KB=%SZ_OUT%/1024
set /a TOTAL_IN_KB+=%SZ_IN_KB%
set /a TOTAL_OUT_KB+=%SZ_OUT_KB%
set /a SAVE_PCT=0
if %SZ_IN_KB% GTR 0 set /a SAVE_PCT=(%SZ_IN_KB%-%SZ_OUT_KB%)*100/%SZ_IN_KB%
echo   %SZ_IN% -^> %SZ_OUT% bytes ^(%SAVE_PCT%%% smaller^)
exit /b 0
