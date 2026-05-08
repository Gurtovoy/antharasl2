@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ============================================================
:: Скрипт сборки и деплоя всех модулей (gameserver, authserver, commons)
:: Собирает проект через локальный Maven, копирует JAR-ы в lib и
:: подтягивает runtime-зависимости (Log4j2, HikariCP, SLF4J, …) в lib.
:: ============================================================

:: Устанавливаем рабочую директорию на папку скрипта
cd /d "%~dp0"

:: Путь к локальному Maven
set "MVN=%~dp0tools\apache-maven-3.9.9\bin\mvn.cmd"

:: Проверяем наличие Maven
if not exist "%MVN%" (
    echo [ОШИБКА] Maven не найден: %MVN%
    pause
    exit /b 1
)

:: Пути деплоя (Windows output)
set "WIN_LIB_ROOT=%~dp0Lib"
set "GS_LIB=%WIN_LIB_ROOT%\gameserver\lib"
set "AS_LIB=%WIN_LIB_ROOT%\authserver\lib"

:: Пути к target-директориям
set "GS_TARGET=%~dp0gameserver\target"
set "AS_TARGET=%~dp0authserver\target"
set "CM_TARGET=%~dp0commons\target"

echo ============================================================
echo  Сборка всех модулей (Java 25, multi-module)
echo  Модули: commons, gameserver, authserver
echo ============================================================
echo.

:: Запуск полной сборки всех модулей
echo [1/5] Запуск Maven сборки...
echo.
call "%MVN%" package -DskipTests -f "%~dp0pom.xml"

:: Проверяем результат сборки
if %ERRORLEVEL% neq 0 (
    echo.
    echo ============================================================
    echo [ОШИБКА] Сборка завершилась с ошибкой! Код: %ERRORLEVEL%
    echo ============================================================
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2/5] Сборка успешна. Ищем JAR-ы для деплоя...
echo.

:: --- Поиск gameserver JAR ---
set "GS_JAR="
for %%f in ("%GS_TARGET%\l2s-gameserver-*.jar") do (
    echo %%~nxf | findstr /i "\-sources \-javadoc" >nul
    if !ERRORLEVEL! neq 0 (
        set "GS_JAR=%%f"
    )
)

:: --- Поиск authserver JAR ---
set "AS_JAR="
for %%f in ("%AS_TARGET%\l2s-authserver-*.jar") do (
    echo %%~nxf | findstr /i "\-sources \-javadoc" >nul
    if !ERRORLEVEL! neq 0 (
        set "AS_JAR=%%f"
    )
)

:: --- Поиск commons JAR ---
set "CM_JAR="
for %%f in ("%CM_TARGET%\l2s-commons-*.jar") do (
    echo %%~nxf | findstr /i "\-sources \-javadoc" >nul
    if !ERRORLEVEL! neq 0 (
        set "CM_JAR=%%f"
    )
)

:: Проверяем что все JAR-ы найдены
set "HAS_ERROR=0"
if not defined GS_JAR (
    echo [ОШИБКА] gameserver JAR не найден в %GS_TARGET%
    set "HAS_ERROR=1"
)
if not defined AS_JAR (
    echo [ОШИБКА] authserver JAR не найден в %AS_TARGET%
    set "HAS_ERROR=1"
)
if not defined CM_JAR (
    echo [ОШИБКА] commons JAR не найден в %CM_TARGET%
    set "HAS_ERROR=1"
)
if "!HAS_ERROR!"=="1" (
    pause
    exit /b 1
)

echo Найдены:
echo   gameserver: %GS_JAR%
echo   authserver: %AS_JAR%
echo   commons:    %CM_JAR%
echo.

:: Создаём директории деплоя если не существуют
echo [3/5] Деплой основных JAR-ов...
if not exist "%GS_LIB%" mkdir "%GS_LIB%"
if not exist "%AS_LIB%" mkdir "%AS_LIB%"

:: --- Копируем gameserver ---
copy /Y "%GS_JAR%" "%GS_LIB%\gameserver.jar" >nul
if %ERRORLEVEL% neq 0 (
    echo [ОШИБКА] Не удалось скопировать gameserver.jar!
    pause
    exit /b 1
)

:: --- Копируем authserver ---
copy /Y "%AS_JAR%" "%AS_LIB%\authserver.jar" >nul
if %ERRORLEVEL% neq 0 (
    echo [ОШИБКА] Не удалось скопировать authserver.jar!
    pause
    exit /b 1
)

:: --- Копируем commons в обе директории ---
copy /Y "%CM_JAR%" "%GS_LIB%\commons.jar" >nul
if %ERRORLEVEL% neq 0 (
    echo [ОШИБКА] Не удалось скопировать commons.jar в gameserver\lib!
    pause
    exit /b 1
)
copy /Y "%CM_JAR%" "%AS_LIB%\commons.jar" >nul
if %ERRORLEVEL% neq 0 (
    echo [ОШИБКА] Не удалось скопировать commons.jar в authserver\lib!
    pause
    exit /b 1
)

echo [4/5] Копирование runtime-зависимостей в Lib, excludeGroupIds=l2s (commons.jar уже скопирован).
echo.

:: Удаляем устаревшие артефакты стека Log4j 1.x / DBCP (если остались от старых сборок)
for %%L in ("%GS_LIB%" "%AS_LIB%") do (
    del /Q "%%~L\log4j-1*.jar" 2>nul
    del /Q "%%~L\slf4j-log4j12*.jar" 2>nul
    del /Q "%%~L\commons-dbcp*.jar" 2>nul
)

call "%MVN%" -q -f "%~dp0pom.xml" -pl gameserver org.apache.maven.plugins:maven-dependency-plugin:3.7.1:copy-dependencies -DoutputDirectory="%GS_LIB%" -DincludeScope=runtime -DexcludeGroupIds=l2s
if %ERRORLEVEL% neq 0 (
    echo [ОШИБКА] copy-dependencies (gameserver) завершился с кодом %ERRORLEVEL%
    pause
    exit /b %ERRORLEVEL%
)

call "%MVN%" -q -f "%~dp0pom.xml" -pl authserver org.apache.maven.plugins:maven-dependency-plugin:3.7.1:copy-dependencies -DoutputDirectory="%AS_LIB%" -DincludeScope=runtime -DexcludeGroupIds=l2s
if %ERRORLEVEL% neq 0 (
    echo [ОШИБКА] copy-dependencies (authserver) завершился с кодом %ERRORLEVEL%
    pause
    exit /b %ERRORLEVEL%
)

echo   Примечание: артефакты со scope system в pom (ecj, trove, napile, …) Maven не копирует — при первой установке положите их в Lib вручную, если их ещё нет.

echo.
echo [5/5] Результаты деплоя (основные JAR-ы):
echo.

for %%f in ("%GS_LIB%\gameserver.jar") do (
    set /a "SZ=%%~zf / 1024"
    echo   gameserver.jar  : !SZ! КБ  ^(%GS_LIB%\gameserver.jar^)
)
for %%f in ("%AS_LIB%\authserver.jar") do (
    set /a "SZ=%%~zf / 1024"
    echo   authserver.jar  : !SZ! КБ  ^(%AS_LIB%\authserver.jar^)
)
for %%f in ("%GS_LIB%\commons.jar") do (
    set /a "SZ=%%~zf / 1024"
    echo   commons.jar (gs): !SZ! КБ  ^(%GS_LIB%\commons.jar^)
)
for %%f in ("%AS_LIB%\commons.jar") do (
    set /a "SZ=%%~zf / 1024"
    echo   commons.jar (as): !SZ! КБ  ^(%AS_LIB%\commons.jar^)
)

echo.
echo ============================================================
echo  ГОТОВО! Сборка, основные JAR-ы и зависимости в Lib.
echo ============================================================
echo.

pause
