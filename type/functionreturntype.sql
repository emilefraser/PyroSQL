SELECT System_type_name FROM sys.dm_exec_describe_first_result_set('
DECLARE @switch char(1) = ''X'';
SELECT CASE WHEN @switch = ''X''
THEN CAST(NULL as numeric(18,2))
ELSE CAST(''100.20'' AS numeric(18,2))
/ 12.0 END', NULL, 1)