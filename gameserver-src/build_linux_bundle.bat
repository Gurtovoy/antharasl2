@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

cd /d "%~dp0"

set "MVN=%~dp0tools\apache-maven-3.9.9\bin\mvn.cmd"
if not exist "%MVN%" (
  echo [ERROR] Maven not found: %MVN%
  exit /b 1
)

set "SRC_GS_LIB=%~dp0..\gameserver\lib"
set "SRC_AS_LIB=%~dp0..\authserver\lib"

set "STAGE_DIR=%~dp0Linux_lib"
set "STAGE_GS_LIB=%STAGE_DIR%\gameserver\lib"
set "STAGE_AS_LIB=%STAGE_DIR%\authserver\lib"

set "GS_TARGET=%~dp0gameserver\target"
set "AS_TARGET=%~dp0authserver\target"
set "CM_TARGET=%~dp0commons\target"

echo ============================================================
echo  Build Linux Bundle (gameserver/authserver libs)
echo ============================================================
echo.

if exist "%STAGE_DIR%" rmdir /s /q "%STAGE_DIR%"
mkdir "%STAGE_GS_LIB%" >nul 2>&1
mkdir "%STAGE_AS_LIB%" >nul 2>&1

echo [0/6] Checking required legacy system jars...
set "MISSING=0"
for %%J in (
  ecj-4.6.1.jar
  trove-3.1a1.jar
  napile-1.0.5b.jar
  javolution-6.1.0.jar
  jacksum-1.7.0.jar
  mesp-1.02.jar
  juniversalchardet-1.0.3.jar
) do (
  if not exist "%SRC_GS_LIB%\%%J" (
    echo [MISSING] %SRC_GS_LIB%\%%J
    set "MISSING=1"
  )
)

if "!MISSING!"=="1" (
  echo.
  echo [ERROR] Missing legacy jars in gameserver\lib. Build cannot continue.
  echo         Restore these files locally first, then rerun script.
  exit /b 1
)

echo.
echo [1/6] Maven install (without auto copy-dependencies)...
call "%MVN%" install -DskipTests -Dmdep.skip=true -f "%~dp0pom.xml"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo.
echo [2/6] Locate main jars...
set "GS_JAR="
for %%f in ("%GS_TARGET%\l2s-gameserver-*.jar") do (
  echo %%~nxf | findstr /i "\-sources \-javadoc" >nul
  if !ERRORLEVEL! neq 0 set "GS_JAR=%%f"
)
set "AS_JAR="
for %%f in ("%AS_TARGET%\l2s-authserver-*.jar") do (
  echo %%~nxf | findstr /i "\-sources \-javadoc" >nul
  if !ERRORLEVEL! neq 0 set "AS_JAR=%%f"
)
set "CM_JAR="
for %%f in ("%CM_TARGET%\l2s-commons-*.jar") do (
  echo %%~nxf | findstr /i "\-sources \-javadoc" >nul
  if !ERRORLEVEL! neq 0 set "CM_JAR=%%f"
)

if not defined GS_JAR (
  echo [ERROR] gameserver jar not found in %GS_TARGET%
  exit /b 1
)
if not defined AS_JAR (
  echo [ERROR] authserver jar not found in %AS_TARGET%
  exit /b 1
)
if not defined CM_JAR (
  echo [ERROR] commons jar not found in %CM_TARGET%
  exit /b 1
)

echo.
echo [3/6] Copy main jars to stage...
copy /Y "%GS_JAR%" "%STAGE_GS_LIB%\gameserver.jar" >nul || exit /b 1
copy /Y "%AS_JAR%" "%STAGE_AS_LIB%\authserver.jar" >nul || exit /b 1
copy /Y "%CM_JAR%" "%STAGE_GS_LIB%\commons.jar" >nul || exit /b 1
copy /Y "%CM_JAR%" "%STAGE_AS_LIB%\commons.jar" >nul || exit /b 1

echo.
echo [4/6] Copy required legacy system jars...
for %%J in (
  ecj-4.6.1.jar
  trove-3.1a1.jar
  napile-1.0.5b.jar
  javolution-6.1.0.jar
  jacksum-1.7.0.jar
  mesp-1.02.jar
  juniversalchardet-1.0.3.jar
) do (
  copy /Y "%SRC_GS_LIB%\%%J" "%STAGE_GS_LIB%\%%J" >nul || exit /b 1
  copy /Y "%SRC_GS_LIB%\%%J" "%STAGE_AS_LIB%\%%J" >nul || exit /b 1
)

echo.
echo [5/6] Copy runtime dependencies to stage...
call "%MVN%" -q -f "%~dp0pom.xml" -pl gameserver org.apache.maven.plugins:maven-dependency-plugin:3.7.1:copy-dependencies -DoutputDirectory="%STAGE_GS_LIB%" -DincludeScope=runtime -DexcludeGroupIds=l2s
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
call "%MVN%" -q -f "%~dp0pom.xml" -pl authserver org.apache.maven.plugins:maven-dependency-plugin:3.7.1:copy-dependencies -DoutputDirectory="%STAGE_AS_LIB%" -DincludeScope=runtime -DexcludeGroupIds=l2s
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

for %%L in ("%STAGE_GS_LIB%" "%STAGE_AS_LIB%") do (
  del /Q "%%~L\log4j-1*.jar" 2>nul
  del /Q "%%~L\slf4j-log4j12*.jar" 2>nul
  del /Q "%%~L\commons-dbcp*.jar" 2>nul
)

set "ZIP_PATH=%~dp0Linux_lib.zip"
if exist "%ZIP_PATH%" del /q "%ZIP_PATH%"

echo.
echo [6/6] Creating zip bundle...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path '%STAGE_DIR%\*' -DestinationPath '%ZIP_PATH%' -Force"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo.
echo ============================================================
echo  DONE
echo  Linux_lib dir: %STAGE_DIR%
echo  Zip file      : %ZIP_PATH%
echo ============================================================
echo.
echo Upload zip to Linux and replace:
echo   1) backup old libs
echo   2) unzip
echo   3) copy Linux_lib\gameserver\lib\* ^-> /home/barsik/gameserver/lib/
echo   4) copy Linux_lib\authserver\lib\* ^-> /home/barsik/authserver/lib/
echo.
exit /b 0
