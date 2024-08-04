@echo off
setlocal

:: Configuración de variables
set "VLC_PATH=C:\Program Files\VideoLAN\VLC\vlc.exe"
set "URL=rtsp://nombredeusuario:tucontraseña@192.168.0.0:554/stream1"
set "BASE_DIR=C:\Users\iroke\Videos"
set "SEQUENCE_FILE=C:\Users\iroke\Videos\sequence.txt"

:: Obtener la fecha y hora actual en formato dd-mm-aaaa_HH-MM-SS
for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set "localdatetime=%%I"
set "year=%localdatetime:~0,4%"
set "month=%localdatetime:~4,2%"
set "day=%localdatetime:~6,2%"
set "hour=%localdatetime:~8,2%"
set "minute=%localdatetime:~10,2%"
set "second=%localdatetime:~12,2%"

:: Formatear la fecha en español
set "currentDate=%day%-%month%-%year%_%hour%-%minute%-%second%"

:: Leer el número de secuencia del archivo
if exist "%SEQUENCE_FILE%" (
    set /p sequence=<"%SEQUENCE_FILE%"
) else (
    set "sequence=0"
)

:: Incrementar el número de secuencia
set /a "sequence+=1"
set "sequence=0000%sequence%"
set "sequence=%sequence:~-4%"

:: Guardar el nuevo número de secuencia en el archivo
echo %sequence% > "%SEQUENCE_FILE%"

:: Crear la carpeta con la fecha actual y el número de secuencia
set "TARGET_DIR=%BASE_DIR%\%currentDate%_%sequence%"
echo Creando carpeta: "%TARGET_DIR%"
mkdir "%TARGET_DIR%"

:: Ejecutar VLC
echo Iniciando VLC...
start "" "%VLC_PATH%" "%URL%" --sout "#duplicate{dst=display,dst=standard{access=file,mux=mp4,dst=%TARGET_DIR%\output.mp4}}"

:: Esperar a que el proceso de VLC termine
:waitForVLC
tasklist /FI "IMAGENAME eq vlc.exe" | find /I "vlc.exe" >nul
if "%ERRORLEVEL%"=="0" (
    timeout /t 5 /nobreak >nul
    goto waitForVLC
)

:: Obtener la fecha y hora actual para la finalización
for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set "localdatetime=%%I"
set "year=%localdatetime:~0,4%"
set "month=%localdatetime:~4,2%"
set "day=%localdatetime:~6,2%"
set "hour=%localdatetime:~8,2%"
set "minute=%localdatetime:~10,2%"
set "second=%localdatetime:~12,2%"

:: Formatear la fecha y hora de finalización en español
set "finishDate=%day%-%month%-%year%_%hour%-%minute%-%second%"

:: Renombrar la carpeta para agregar el sufijo "finalizado" y la hora de finalización
set "RENAMED_DIR=%BASE_DIR%\finalizado_%finishDate%_%sequence%"
echo Renombrando carpeta de "%TARGET_DIR%" a "%RENAMED_DIR%"
ren "%TARGET_DIR%" "finalizado_%finishDate%_%sequence%"

:: Mostrar mensaje de finalización
echo Finalizado %finishDate%_%sequence%
pause