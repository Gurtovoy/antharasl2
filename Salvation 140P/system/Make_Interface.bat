@echo off
cd %~dp0
del Core.u
del Engine.u 
del NWindow.u 
del Interface.u
ucc make -NoBind
pause