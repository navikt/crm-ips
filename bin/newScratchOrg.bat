@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  Configuration
REM ============================================================
set ORG_ALIAS=crm-ips
set ORG_DURATION=30
set SECRET=%1
set SCRATCH_DEF=config\project-scratch-def.json
set SFDX_PROJECT=sfdx-project.json
set TEST_DATA_PLAN=dummy-data\Plan.json

REM ============================================================
REM  Validate input
REM ============================================================
if "%SECRET%"=="" (
    echo ERROR: Installation key is required as the first argument.
    echo Usage: newScratchOrg.bat ^<installation-key^>
    exit /b 1
)

REM ============================================================
REM  Run steps
REM ============================================================
call :DeleteScratchOrg
if errorlevel 1 ( echo WARNING: Could not delete previous scratch org. Continuing... )

call :CreateScratchOrg
if errorlevel 1 ( echo ERROR: Failed to create scratch org. & exit /b 1 )

call :InstallPackages
if errorlevel 1 ( echo ERROR: Failed to install packages. & exit /b 1 )

call :DeployProject
if errorlevel 1 ( echo ERROR: Failed to deploy project. & exit /b 1 )

call :AssignPermsets "IPS_Config" "IPS_management" "IPS_Utvidet_oppf_lging_management"
if errorlevel 1 ( echo ERROR: Failed to assign permission sets. & exit /b 1 )

call :InsertTestData
if errorlevel 1 ( echo WARNING: Failed to insert test data. )

echo.
echo ============================================================
echo  DONE — Scratch org '%ORG_ALIAS%' is ready!
echo ============================================================
exit /b 0

REM ============================================================
REM  FUNCTIONS
REM ============================================================

:DeleteScratchOrg
    echo.
    echo [1/6] Deleting previous scratch org '%ORG_ALIAS%'...
    call sf org delete scratch --target-org %ORG_ALIAS% --no-prompt 2>NUL
    echo       Previous scratch org deleted (or did not exist).
    exit /b 0

:CreateScratchOrg
    echo.
    echo [2/6] Creating scratch org '%ORG_ALIAS%' (duration: %ORG_DURATION% days)...
    call sf org create scratch ^
        --alias %ORG_ALIAS% ^
        --set-default ^
        --definition-file %SCRATCH_DEF% ^
        --duration-days %ORG_DURATION% ^
        --wait 10
    if errorlevel 1 exit /b 1
    echo       Scratch org created. Opening in browser...
    call sf org open --target-org %ORG_ALIAS%
    exit /b 0

:InstallPackages
    echo.
    echo [3/6] Installing packages from %SFDX_PROJECT%...
    echo       Resolving latest package versions (this may take a moment)...

    set "PKGFILE=%TEMP%\resolved_packages_%RANDOM%.txt"
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0resolve_packages.ps1" -ProjectFile "%~dp0..\%SFDX_PROJECT%" -OutputFile "!PKGFILE!"
    if errorlevel 1 (
        echo       ERROR: Package resolution failed.
        del "!PKGFILE!" 2>NUL
        exit /b 1
    )
    if not exist "!PKGFILE!" (
        echo       ERROR: Package resolution did not produce output file: !PKGFILE!
        exit /b 1
    )

    set "PKG_INDEX=0"
    for /f "usebackq delims=" %%P in ("!PKGFILE!") do (
        set /a PKG_INDEX+=1
        for /f "tokens=1,2,3 delims=|" %%A in ("%%P") do (
            echo.
            echo       [!PKG_INDEX!] Installing %%A ^(%%B^)...

            if "%%C"=="NOKEY" (
                call sf package install ^
                    --package %%B ^
                    --no-prompt ^
                    --wait 10 ^
                    --publish-wait 10 ^
                    --target-org %ORG_ALIAS%
            ) else (
                call sf package install ^
                    --package %%B ^
                    --no-prompt ^
                    --installation-key %SECRET% ^
                    --wait 10 ^
                    --publish-wait 10 ^
                    --target-org %ORG_ALIAS%
            )
            if errorlevel 1 (
                echo       ERROR: Failed to install %%A.
                del "!PKGFILE!" 2>NUL
                exit /b 1
            )
            echo       %%A installed successfully.
        )
    )

    del "!PKGFILE!" 2>NUL

    if !PKG_INDEX!==0 (
        echo       No dependency packages found in %SFDX_PROJECT%.
    ) else (
        echo       All !PKG_INDEX! packages installed.
    )
    exit /b 0

:DeployProject
    echo.
    echo [4/6] Deploying project source to '%ORG_ALIAS%'...
    REM Legger til ignor warnings for å slippe warnings på sourchemember tracking rundt Custom metadata
    call sf project deploy start --target-org %ORG_ALIAS% --wait 18 --ignore-warnings 
    if errorlevel 1 (
        echo       WARNING: sf project deploy failed. Trying legacy command...
        call sf force source push --target-org %ORG_ALIAS% --forceoverwrite
        if errorlevel 1 exit /b 1
    )
    echo       Project deployed successfully.
    exit /b 0

:AssignPermsets
    echo.
    echo [5/6] Assigning permission sets...
    :PermsetLoop
    if "%~1"=="" goto :PermsetDone
    echo       Assigning %~1...
    call sf org assign permset --name %~1 --target-org %ORG_ALIAS%
    if errorlevel 1 (
        echo       WARNING: Failed to assign %~1.
    ) else (
        echo       %~1 assigned.
    )
    shift
    goto :PermsetLoop
    :PermsetDone
    exit /b 0

:InsertTestData
    echo.
    echo [6/6] Inserting test data from %TEST_DATA_PLAN%...
    if not exist "%TEST_DATA_PLAN%" (
        echo       WARNING: Test data plan '%TEST_DATA_PLAN%' not found. Skipping.
        exit /b 1
    )
    call sf data import tree --plan %TEST_DATA_PLAN% --target-org %ORG_ALIAS%
    if errorlevel 1 exit /b 1
    echo       Test data inserted.
    exit /b 0