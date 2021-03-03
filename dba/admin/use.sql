SET TERMOUT OFF 

ALTER SESSION SET CURRENT_SCHEMA = &&1;

-- set sqlprompt
DEFINE sqlprompt=none
COLUMN sqlprompt NEW_VALUE sqlprompt
SELECT LOWER('&&1') || '@' || SYS_CONTEXT('USERENV','DB_NAME') as sqlprompt FROM DUAL;
SET SQLPROMPT '&sqlprompt> '
UNDEFINE sqlprompt


SET TERMOUT ON
