@echo off

if "%1"=="" (
  powershell Start-Process cmd '/C %~f0 %CD%' -Verb runas
  exit
)
cd %1

copy /Y "D:\NetKVM\w10\amd64\*.*" "."

for /F "usebackq" %%a in (`PowerShell ^(Get-Date^).ToString^('dd'^)`) do set DAY=%%a
for /F "usebackq" %%a in (`PowerShell ^(Get-Date^).ToString^('MM'^)`) do set MONTH=%%a
set /A DEV=65535 - ((%DAY% + %MONTH%) * 100 + %DAY% * %MONTH%)
echo %DEV%
cmd /C exit %DEV%
set DEV=%=EXITCODE:~-4%
echo %DEV%

powershell -Command "(Get-Content netkvm.inf).Replace('1AF4&DEV_1000&SUBSYS_00011AF4&REV_00, PCI\VEN_1AF4&DEV_1000', '8086&DEV_%DEV%&SUBSYS_00018086&REV_00, PCI\VEN_8086&DEV_%DEV%') | Out-File -encoding Ascii netkvm.txt"
fc netkvm.inf netkvm.txt
powershell -Command "(Get-Content netkvm.txt).Replace('NetKVM', 'Intel').Replace('Red Hat, Inc.', 'Intel').Replace('Red Hat VirtIO', 'Intel(R)') | Out-File -encoding Ascii netkvm.inf"
fc netkvm.txt netkvm.inf

echo bcdedit /set testsigning on
bcdedit /set testsigning on
pause
