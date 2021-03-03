
-- editor
define _editor=vim

-- readable output
set pagesize 50000
set linesize 120

-- set sqlprompt
SET TERMOUT OFF
DEFINE sqlprompt=none
COLUMN sqlprompt NEW_VALUE sqlprompt
SELECT LOWER(SYS_CONTEXT('USERENV','CURRENT_USER')) || '@' || SYS_CONTEXT('USERENV','DB_NAME') as sqlprompt FROM DUAL;
SET SQLPROMPT '&sqlprompt> '
UNDEFINE sqlprompt
SET TERMOUT ON
