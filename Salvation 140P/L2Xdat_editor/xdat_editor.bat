@echo off
set "JAVA_HOME=C:\Program Files\BellSoft\LibericaJDK-25"
set "PATH=%JAVA_HOME%\bin;%PATH%"
set "FX=C:\path\to\javafx-sdk-25\lib"
java --module-path "%FX%" --add-modules javafx.controls,javafx.fxml -cp "./build/kernel/editor.jar;./lib/*" -Dfile.encoding=UTF-8 acmi.l2.clientmod.xdat.XdatEditor
pause