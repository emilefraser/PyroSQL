@ECHO OFF

SET servername="%1"
SET databasename="%2"
SET username="%3"
SET password="%4"

SET servername="mssql.docker.local,16433"
SET databasename="PyroDictionaryDB"
SET username="sa"
SET password="105022_Alpha"

FOR /f %%i IN ('DIR *.sql /B') do call :RunScript %%i
GOTO :END

 

:RunScript

Echo Executing %1
SQLCMD -S %servername% -d %databasename% -U %username% -P %password% -i %1
Echo Completed %1

:END