@echo off

if "%1"=="" (
  powershell Start-Process cmd '/C %~f0 %CD%' -Verb runas
  exit
)
cd %1

for /F "usebackq" %%a in (`PowerShell ^(Get-Date^).ToString^('dd'^)`) do set DAY=%%a
for /F "usebackq" %%a in (`PowerShell ^(Get-Date^).ToString^('MM'^)`) do set MONTH=%%a
set /A DEV=49152 + (%DAY% + %MONTH%) * 100 + %DAY% * %MONTH%
echo %DEV%
cmd /C exit %DEV%
set DEV=%=EXITCODE:~-4%
echo %DEV%

copy /Y "D:\NetKVM\w10\amd64\netkvm.*" "%DEV%.*"
copy /Y "D:\NetKVM\w10\amd64\netkvmp.exe" "%DEV%.exe"

powershell -Command "(Get-Content %DEV%.inf).Replace('1AF4&DEV_1000&SUBSYS_00011AF4&REV_00, PCI\VEN_1AF4&DEV_1000', '8086&DEV_%DEV%&SUBSYS_00018086&REV_00, PCI\VEN_8086&DEV_%DEV%').Replace('kvmnet6', '%DEV%').Replace('netkvmp', '%DEV%') | Out-File -encoding Ascii %DEV%.txt"
fc %DEV%.inf %DEV%.txt
powershell -Command "(Get-Content %DEV%.txt).Replace('netkvm', '%DEV%').Replace('NetKVM', 'Intel').Replace('Red Hat, Inc.', 'Intel').Replace('Red Hat VirtIO', 'Intel(R)') | Out-File -encoding Ascii %DEV%.inf"
fc %DEV%.txt %DEV%.inf

echo bcdedit /set testsigning on
bcdedit /set testsigning on
pause
