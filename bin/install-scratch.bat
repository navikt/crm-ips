@echo off
setlocal enabledelayedexpansion

REM Set variables
set SCRIPT_PATH=%~dp0
cd /d "%SCRIPT_PATH%.."

set ORG_ALIAS=crm-ips
set ORG_DURATION=30
set SECRET=%1
set TEMP_FILE=package_aliases.txt
set PACKAGE_LIST_FILE=package_list.txt
set DEBUG_FILE=package_debug.txt

REM Fetch DevHub Alias
for /f "tokens=2 delims=: " %%A in ('sf config get target-dev-hub --json') do (
    set DEV_HUB_ALIAS=%%A
)

REM Search for sfdx-project.json in the current directory and subdirectories
for /f "delims=" %%F in ('dir /b /s sfdx-project.json') do (
    set SFDX_PROJECT_JSON=%%F
    goto :found
)
:found
echo ************** Found sfdx-project.json at: %SFDX_PROJECT_JSON% **************

REM Check if the package key is provided
if "%SECRET%"=="" (
    echo ************** Package key is required. **************
    exit /b 1
)

REM Fetch the list of packages and map 0Ho IDs to 04t IDs
echo ************** Fetching package versions... **************

REM Create a temporary file to store package aliases from sfdx-project.json
for /f "delims=" %%L in ('type "%SFDX_PROJECT_JSON%" ^| findstr /i "0Ho"') do (
    set LINE=%%L
    set LINE=!LINE:"=!
    set LINE=!LINE:,=!
    set LINE=!LINE: =!
    set LINE=!LINE:	=!

    REM Skip empty lines
    if not "!LINE!"=="" (
        echo !LINE! >> "%TEMP_FILE%"
    )
)

REM Remove the last line containing crm-ips
echo ************** Removing crm-ips line **************
for /f "delims=" %%L in ('findstr /v /i "crm-ips" "%TEMP_FILE%"') do (
    echo %%L >> "%TEMP_FILE%.tmp"
)

REM Replace TEMP_FILE with the cleaned version
move /y "%TEMP_FILE%.tmp" "%TEMP_FILE%"

REM  REM Find the latest version of the package using PowerShell to get the last line
    for /f "tokens=1,2* delims=:"  %%A in ('type "%TEMP_FILE%"') do (
        
        REM Check if the package ID is not empty
        if not %%B==" " (
             echo ************** Processing package %%A with ID %%B  **************
            sf package version list --released --concise --order-by PatchVersion --packages %%B >> "%PACKAGE_LIST_FILE%"

            for /F "delims=" %%C in ("%PACKAGE_LIST_FILE%") do (
                set LASTLINE=%%C

                REM Skip empty lines
                if not "!LASTLINE!"=="" (
                    echo %LASTLINE% >> "%DEBUG_FILE%"
                )
            )
        ) else (
            echo %%A has no ID, skipping...
        )
    )



echo ************** Installation completed successfully **************
REM Remove the temporary file
del "%TEMP_FILE%"
del "%PACKAGE_LIST_FILE%"
del "%DEBUG_FILE%"
ENDLOCAL
exit /b 0