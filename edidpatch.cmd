@echo off
setlocal ENABLEDELAYEDEXPANSION

if "%1"=="" (
  echo usage: %~nx0 edidfile.bin
  goto :_END
)

certutil -f -encodehex "%1" "in.hex" 12>NUL
set /P VAR=<in.hex

set AUX=%VAR%
set SIZE=0
:_LOOP
if not "%AUX%"=="" (
  set AUX=%AUX:~1%
  set /A SIZE+=1
  goto :_LOOP
)
set /A AUX=%SIZE%/2
echo %1 %AUX% bytes

set /A MANUFACTURER=0x%VAR:~16,4%
set /A CHAR_C=(%MANUFACTURER% ^& 0x001F)        + 64
cmd /C exit %CHAR_C%
set CHAR_C=!=exitcodeAscii!
set /A CHAR_B=(%MANUFACTURER% ^& 0x03E0) / 32   + 64
cmd /C exit %CHAR_B%
set CHAR_B=!=exitcodeAscii!
set /A CHAR_A=(%MANUFACTURER% ^& 0x7C00) / 1024 + 64
cmd /C exit %CHAR_A%
set CHAR_A=!=exitcodeAscii!
echo     id:%VAR:~16,4% (%CHAR_A%%CHAR_B%%CHAR_C%)
echo  model:%VAR:~20,4% (%VAR:~22,2%%VAR:~20,2%)

set /A SERIAL=0x%VAR:~30,2%%VAR:~28,2%%VAR:~26,2%%VAR:~24,2%
echo serial:%VAR:~24,8% (%SERIAL%)
call :_GET_RANDOM_HEX
set SERIAL_HEX=%OUTPUT:~0,6%00
set /A SERIAL=0x%SERIAL_HEX:~6,2%%SERIAL_HEX:~4,2%%SERIAL_HEX:~2,2%%SERIAL_HEX:~0,2%
echo serial:%SERIAL_HEX% (%SERIAL%)

echo   week:%VAR:~32,2%
set /A YEAR=0x%VAR:~34,2% + 1990
echo   year:%VAR:~34,2% (1990 + 0x%VAR:~34,2% = %YEAR%)

set SLOT_1=
for /L %%I in (118,2,144) do (
  set /A CHAR_I=0x!VAR:~%%I,2!
  cmd /C exit !CHAR_I!
  set CHAR_I=!=exitcodeAscii!
  set SLOT_1=!SLOT_1!!CHAR_I!
)
echo slot_1:%VAR:~118,26% "%SLOT_1%"

set SLOT_2=
for /L %%I in (154,2,180) do (
  set /A CHAR_I=0x!VAR:~%%I,2!
  cmd /C exit !CHAR_I!
  set CHAR_I=!=exitcodeAscii!
  set SLOT_2=!SLOT_2!!CHAR_I!
)
echo slot_2:%VAR:~154,26% "%SLOT_2%"

call :_GET_RANDOM_SERIAL
set STRING_N_HEX=%OUTPUT_HEX%
set SLOT_N_HEX=%VAR:~154,26%
set SLOT_N=
call :_PATCH_EDID_SLOT
if not "SLOT_N"=="" (
  set SLOT_2=%SLOT_N%
  set SLOT_2_HEX=%SLOT_N_HEX%
)

set SLOT_3=
for /L %%I in (190,2,216) do (
  set /A CHAR_I=0x!VAR:~%%I,2!
  cmd /C exit !CHAR_I!
  set CHAR_I=!=exitcodeAscii!
  set SLOT_3=!SLOT_3!!CHAR_I!
)
echo slot_3:%VAR:~190,26% "%SLOT_3%"

call :_GET_RANDOM_SERIAL
set STRING_N_HEX=%OUTPUT_HEX%
set SLOT_N_HEX=%VAR:~190,26%
set SLOT_N=
call :_PATCH_EDID_SLOT
if not "SLOT_N"=="" (
  set SLOT_3=%SLOT_N%
  set SLOT_3_HEX=%SLOT_N_HEX%
)

set SLOT_4=
for /L %%I in (226,2,250) do (
  set /A CHAR_I=0x!VAR:~%%I,2!
  cmd /C exit !CHAR_I!
  set CHAR_I=!=exitcodeAscii!
  set SLOT_4=!SLOT_4!!CHAR_I!
)
echo slot_4:%VAR:~226,26% "%SLOT_4%"

set AUX=%VAR:~0,24%%SERIAL_HEX%%VAR:~32,112%%VAR:~144,10%%SLOT_2_HEX%%VAR:~180,10%%SLOT_3_HEX%%VAR:~216,296%
echo %AUX%>out.hex
certutil -f -decodehex "out.hex" "out.bin" 12>NUL
fc /B "%1" "out.bin"
pause
goto :_END


:_GET_RANDOM_HEX
set "CHARSET=0123456789abcdef"
set OUTPUT=
for /L %%I in (1,1,8) do (
  set /A INDEX=!RANDOM! %% 16
  for %%J in (!INDEX!) do set OUTPUT=!OUTPUT!!CHARSET:~%%J,1!
)
goto :_END

:_GET_RANDOM_SERIAL
set "CHARSET=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
set OUTPUT=
for /L %%I in (1,1,13) do (
  set /A INDEX=!RANDOM! %% 36
  for %%J in (!INDEX!) do set OUTPUT=!OUTPUT!!CHARSET:~%%J,1!
)
<NUL set /P="%OUTPUT%" >temp.txt
certutil -f -encodehex "temp.txt" "temp.hex" 12>NUL
set /P OUTPUT_HEX=<temp.hex
goto :_END

:_PATCH_EDID_SLOT
for /L %%I in (0,2,22) do (
  if not "!SLOT_N_HEX:~%%I,2!"=="00" (
    set /A I_2=%%I + 2
    for %%J in (!I_2!) do (
      if "!SLOT_N_HEX:~%%J,2!"=="0a" (
        set AUX=
        for /L %%K in (0,2,24) do (
          if "%%K" LEQ "%%I" (
            set AUX=!AUX!!STRING_N_HEX:~%%K,2!
          ) else (
            set AUX=!AUX!!SLOT_N_HEX:~%%K,2!
          )
        )
        set SLOT_N_HEX=!AUX!
        set SLOT_N=
        for /L %%L in (0,2,24) do (
          set /A CHAR_I=0x!SLOT_N_HEX:~%%L,2!
          cmd /C exit !CHAR_I!
          set CHAR_I=!=exitcodeAscii!
          set SLOT_N=!SLOT_N!!CHAR_I!
        )
        echo slot_n:!SLOT_N_HEX! "!SLOT_N!"
      )
    )
  )
)
goto :_END

:_END
