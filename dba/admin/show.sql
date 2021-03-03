DEF arg='&&1'
DEF opt='&&2'
COLUMN  script_name_col	NEW_VALUE script_name
 
SELECT	CASE
		WHEN LOWER('&arg') = 'code' THEN 'showcode.sql &opt'
		WHEN LOWER('&arg') = 'packages' THEN 'showpackages.sql &opt'
		WHEN LOWER('&arg') = 'tables' THEN 'showtables.sql &opt'
		ELSE  'showdatabases.sql'
	END	AS script_name_col
FROM	dual;
 
--	do:
@&script_name
UNDEF arg
UNDEF opt
