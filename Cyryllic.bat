@echo off
chcp 65001 > nul
REM Запуск от имени администратора
NET FILE >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    PowerShell -Command "Start-Process -Verb RunAs '%~f0' -ArgumentList '%~1'" 
    EXIT /B
)

echo Настройка системы для корректной работы с кириллицей...
echo ------------------------------------------------

REM 1. Установка UTF-8 для консоли
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Command Processor" /v "AutoRun" /t REG_SZ /d "chcp 65001 > nul" /f

REM 2. Кодовая страница по умолчанию
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Nls\CodePage" /v "OEMCP" /t REG_SZ /d "65001" /f

REM 3. Исправление локали (корректный параметр для Windows 10/11)
reg add "HKEY_CURRENT_USER\Control Panel\International" /v "LocaleName" /t REG_SZ /d "ru-RU" /f
reg add "HKEY_CURRENT_USER\Control Panel\International" /v "Locale" /t REG_SZ /d "00000419" /f 2>nul

REM 4. Шрифт консоли
reg add "HKEY_CURRENT_USER\Console" /v "FaceName" /t REG_SZ /d "Lucida Console" /f
reg add "HKEY_CURRENT_USER\Console" /v "FontFamily" /t REG_DWORD /d 54 /f
reg add HKEY_CURRENT_USER\Console /v FontSize /t REG_DWORD /d 0x000c0000 /f
REG add HKEY_CURRENT_USER\Console /v ScreenColors /t REG_DWORD /d 0xf0 /f

REM 5. Для PowerShell
if exist "%USERPROFILE%\Documents\WindowsPowerShell\" (
    echo $OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8 > "%USERPROFILE%\Documents\WindowsPowerShell\profile.ps1"
    echo [Console]::InputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 >> "%USERPROFILE%\Documents\WindowsPowerShell\profile.ps1"
)

echo ------------------------------------------------
echo Готово! Перезапустите консоль.
echo Если проблемы остались, перезагрузите систему.
pause