@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

cd /d "%~dp0"

set "MVN=%~dp0tools\apache-maven-3.9.9\bin\mvn.cmd"
if not exist "%MVN%" (
  echo [ERROR] Maven not found: %MVN%
  exit /b 1
)

set "ROOT_GAME=%~dp0..\gameserver"
set "ROOT_AUTH=%~dp0..\authserver"
set "SRC_GS_LIB=%ROOT_GAME%\lib"
set "SRC_AS_LIB=%ROOT_AUTH%\lib"
set "SRC_GS_CFG=%ROOT_GAME%\config"
set "SRC_AS_CFG=%ROOT_AUTH%\config"

set "STAGE_DIR=%~dp0Linux_lib"
set "STAGE_GS_LIB=%STAGE_DIR%\gameserver\lib"
set "STAGE_AS_LIB=%STAGE_DIR%\authserver\lib"
set "STAGE_GS_CFG=%STAGE_DIR%\gameserver\config"
set "STAGE_AS_CFG=%STAGE_DIR%\authserver\config"

set "GS_TARGET=%~dp0gameserver\target"
set "AS_TARGET=%~dp0authserver\target"
set "CM_TARGET=%~dp0commons\target"

echo ============================================================
echo  Build Linux bundle: JARs + runtime deps + config (for Ubuntu)
echo ============================================================
echo.

if exist "%STAGE_DIR%" rmdir /s /q "%STAGE_DIR%"
mkdir "%STAGE_GS_LIB%" >nul 2>&1
mkdir "%STAGE_AS_LIB%" >nul 2>&1
mkdir "%STAGE_GS_CFG%" >nul 2>&1
mkdir "%STAGE_AS_CFG%" >nul 2>&1

echo [0/8] Checking required legacy system jars in gameserver\lib...
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

if not exist "%SRC_GS_CFG%" (
  echo [ERROR] Gameserver config not found: %SRC_GS_CFG%
  exit /b 1
)

echo.
echo [1/8] Maven install (mdep.skip — dependencies copied in a later step^)...
call "%MVN%" install -DskipTests -Dmdep.skip=true -f "%~dp0pom.xml"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo.
echo [2/8] Locate main jars (same rules as build.bat: exclude -sources / -javadoc^)...
set "GS_JAR="
for %%f in ("%GS_TARGET%\l2s-gameserver-*.jar") do (
  echo %%~nxf | findstr /i "\-sources \-javadoc" >nul
  if !ERRORLEVEL! neq 0 (
    set "GS_JAR=%%f"
  )
)
set "AS_JAR="
for %%f in ("%AS_TARGET%\l2s-authserver-*.jar") do (
  echo %%~nxf | findstr /i "\-sources \-javadoc" >nul
  if !ERRORLEVEL! neq 0 (
    set "AS_JAR=%%f"
  )
)
set "CM_JAR="
for %%f in ("%CM_TARGET%\l2s-commons-*.jar") do (
  echo %%~nxf | findstr /i "\-sources \-javadoc" >nul
  if !ERRORLEVEL! neq 0 (
    set "CM_JAR=%%f"
  )
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
echo   gameserver: !GS_JAR!
echo   authserver: !AS_JAR!
echo   commons:    !CM_JAR!

echo.
echo [3/8] Copy main jars to Linux_lib\...\lib ...
copy /Y "%GS_JAR%" "%STAGE_GS_LIB%\gameserver.jar" >nul || exit /b 1
copy /Y "%AS_JAR%" "%STAGE_AS_LIB%\authserver.jar" >nul || exit /b 1
copy /Y "%CM_JAR%" "%STAGE_GS_LIB%\commons.jar" >nul || exit /b 1
copy /Y "%CM_JAR%" "%STAGE_AS_LIB%\commons.jar" >nul || exit /b 1

echo.
echo [4/8] Copy required legacy system jars...
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
echo [5/8] Copy Maven runtime dependencies to stage lib...
call "%MVN%" -q -f "%~dp0pom.xml" -pl gameserver org.apache.maven.plugins:maven-dependency-plugin:3.7.1:copy-dependencies -DoutputDirectory="%STAGE_GS_LIB%" -DincludeScope=runtime -DexcludeGroupIds=l2s
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
call "%MVN%" -q -f "%~dp0pom.xml" -pl authserver org.apache.maven.plugins:maven-dependency-plugin:3.7.1:copy-dependencies -DoutputDirectory="%STAGE_AS_LIB%" -DincludeScope=runtime -DexcludeGroupIds=l2s
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

for %%L in ("%STAGE_GS_LIB%" "%STAGE_AS_LIB%") do (
  del /Q "%%~L\log4j-1*.jar" 2>nul
  del /Q "%%~L\slf4j-log4j12*.jar" 2>nul
  del /Q "%%~L\commons-dbcp*.jar" 2>nul
)

echo.
echo [6/8] Copy gameserver/authserver config trees (same as repo antharasl2\gameserver|authserver\config^)...
robocopy "%SRC_GS_CFG%" "%STAGE_GS_CFG%" /E /NFL /NDL /NJH /NJS /NC /NS
set "RC=!ERRORLEVEL!"
if !RC! GEQ 8 (
  echo [ERROR] robocopy gameserver config failed, code !RC!
  exit /b 1
)
if exist "%SRC_AS_CFG%" (
  robocopy "%SRC_AS_CFG%" "%STAGE_AS_CFG%" /E /NFL /NDL /NJH /NJS /NC /NS
  set "RC=!ERRORLEVEL!"
  if !RC! GEQ 8 (
    echo [ERROR] robocopy authserver config failed, code !RC!
    exit /b 1
  )
) else (
  echo [WARN] Authserver config missing, skip: %SRC_AS_CFG%
)

echo.
echo [7/8] Write README_DEPLOY.txt ...
(
  echo Linux_lib — готово к выгрузке на Ubuntu
  echo.
  echo 1^) Остановить gameserver и authserver.
  echo 2^) Бэкап: .../gameserver/lib и .../gameserver/config ^(и authserver^).
  echo 3^) Скопировать содержимое:
  echo      Linux_lib\gameserver\lib\*     -^> PROD/gameserver/lib/
  echo      Linux_lib\authserver\lib\*     -^> PROD/authserver/lib/
  echo 4^) Конфиги: смержить или заменить дерево:
  echo      Linux_lib\gameserver\config\*  -^> PROD/gameserver/config/
  echo      Linux_lib\authserver\config\* -^> PROD/authserver/config/
  echo     ВНИМАНИЕ: на проде свои пароли БД в server.properties/authserver.properties —
  echo     не затирайте файл целиком, если не уверены; перенесите нужные ключи.
  echo.
  echo Почта ^(gameserver config/server.properties^):
  echo   AllowMail = True
  echo   MailPeaceZoneOnly = False
  echo   MailClientCompassPeaceOpenWorld = True
  echo Почта CB ^(gameserver config/bbs.properties^):
  echo   BBS_MAIL_RESPECT_GLOBAL_PEACE_ZONE_ONLY = False
  echo.
  echo 5^) Запустить сервера заново.
) > "%STAGE_DIR%\README_DEPLOY.txt"

set "ZIP_PATH=%~dp0Linux_lib.zip"
if exist "%ZIP_PATH%" del /q "%ZIP_PATH%"

echo.
echo [8/8] Creating Linux_lib.zip ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path '%STAGE_DIR%\*' -DestinationPath '%ZIP_PATH%' -Force"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo.
echo ============================================================
echo  DONE
echo  Folder: %STAGE_DIR%
echo  Zip:    %ZIP_PATH%
echo ============================================================
echo.
echo На сервере должны совпасть И jar из lib, И актуальные ключи в config.
echo.
exit /b 0
