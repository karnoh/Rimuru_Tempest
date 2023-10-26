@ECHO OFF

IF "%1" == "" GOTO No1Arg

SET dbname=%1
SET montime=%2

IF NOT "%montime%" == "" CALL :MonTimeCheck %montime%
IF %ERRORLEVEL% NEQ 0 GOTO :EOF

PUSHD %~dp0
SET scriptRoot=%CD%
POPD

ECHO Scipts should be found in %scriptRoot%

db2 -v connect to %dbName%
db2 -v create bufferpool db2monbp
db2 -v create user temporary tablespace db2montmptbsp bufferpool db2monbp

db2 +c -tvf "%scriptRoot%\db2monBefore.sql"

IF "%montime%" == "" (
  db2 +c -tvf "%scriptRoot%\db2monInterval.sql"
  GOTO Db2MonAfter
)

IF %montime% EQU 0 (
  SET /P=Hit enter to finish monitoring
  GOTO Db2MonAfter
)

TIMEOUT /T %montime% /NOBREAK

:Db2MonAfter

db2 +c -tvf "%scriptRoot%\db2monAfter.sql"

db2 -v commit work
db2 -v connect reset
db2 -v terminate

db2 -v connect to %dbName%
db2 -v drop tablespace db2montmptbsp
db2 -v drop bufferpool db2monbp
db2 -v connect reset
db2 -v terminate

GOTO :EOF

:No1Arg
  ECHO Usage: %0 ^<Database Name^> [Monitor Interval]
  GOTO :EOF

:MonTimeCheck
  SET /A montime_check=%~1
  IF %montime_check% NEQ %~1 GOTO MonTimeNotNumber
  IF NOT %~1 GEQ 0 GOTO MonTimeNegative
  IF %~1 EQU 0 (
    ECHO Monitoring interval set to zero - press enter to end monitoring interval
  ) ELSE ECHO Monitoring interval set to %montime% second(s)
  EXIT /B 0

:MonTimeNotNumber
  ECHO Monitoring interval %montime% does not appear to be a number
  EXIT /B 1

:MonTimeNegative
  ECHO Monitoring interval %montime% is negative - only positive intervals are supported
  EXIT /B 1

