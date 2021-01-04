SELECT DEV.name as DEV_ColumnName, 
PROD.name as PROD_ColumnName, 
DEV.is_nullable as DEV_is_nullable, 
PROD.is_nullable as PROD_is_nullable, 
DEV.system_type_name as DEV_Datatype, 
PROD.system_type_name as PROD_Datatype, 
DEV.is_identity_column as DEV_is_identity, 
PROD.is_identity_column as PROD_is_identity  
FROM sys.dm_exec_describe_first_result_set (N'SELECT * FROM dbo.WebUsers', NULL, 0) DEV 
FULL OUTER JOIN  sys.dm_exec_describe_first_result_set (N'SELECT * FROM dbo.WebUsers2', NULL, 0) PROD 
ON DEV.name = PROD.name 
GO