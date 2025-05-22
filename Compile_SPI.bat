@echo off
setlocal

:: Mostrar la hora de inicio
echo ===============================
echo Iniciando script a las: %time%
echo ===============================

:: Inicializar contador (simulado con un loop)
set /a contador=0

:: Ejecutar el script de PowerShell
powershell -ExecutionPolicy Bypass -NoLogo -NoProfile -File "C:\Users\miguelrobles\Desktop\autohotkey\compile_script.ps1"

:: Aumentar contador (puedes ajustar según tu lógica)
set /a contador+=1

:: Mostrar la hora de finalización y contador
echo ===============================
echo Script finalizado a las: %time%
echo Total de ejecuciones: %contador%
echo ===============================