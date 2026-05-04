@echo off
title L2-Scripts Classic: Saviors (Antharas) (Game Server)

:start
echo Starting GameServer.
echo.

java -server -Dfile.encoding=UTF-8 -Xms2g -Xmx16g ^
 --add-opens java.base/java.lang=ALL-UNNAMED ^
 --add-opens java.base/java.lang.reflect=ALL-UNNAMED ^
 --add-opens java.base/java.io=ALL-UNNAMED ^
 --add-opens java.base/java.util=ALL-UNNAMED ^
 --add-opens java.base/java.util.concurrent=ALL-UNNAMED ^
 --add-opens java.base/java.net=ALL-UNNAMED ^
 --add-opens java.base/sun.nio.ch=ALL-UNNAMED ^
 --add-opens java.base/sun.security.ssl=ALL-UNNAMED ^
 --add-opens java.base/java.lang.invoke=ALL-UNNAMED ^
 -cp config;./lib/* l2s.gameserver.GameServer

if ERRORLEVEL 2 goto restart
if ERRORLEVEL 1 goto error
goto end
:restart
echo.
echo Server restarted ...
echo.
goto start
:error
echo.
echo Server terminated abnormaly ...
echo.
:end
echo.
echo Server terminated ...
echo.

pause
