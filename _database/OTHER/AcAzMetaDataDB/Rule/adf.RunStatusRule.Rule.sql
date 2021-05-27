IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[RunStatusRule]') AND OBJECTPROPERTY(object_id, N'IsRule') = 1)
EXEC dbo.sp_executesql N'CREATE RULE [adf].[RunStatusRule] 
AS
CONVERT(VARCHAR(100), @RunStatus) IN (
	CONVERT(VARCHAR(100), ''Execution - Started'')
,	CONVERT(VARCHAR(100), ''Error - General'')
,	CONVERT(VARCHAR(100), ''Executing - Full Load'')
,	CONVERT(VARCHAR(100), ''Executing - Incremental Load'')
,	CONVERT(VARCHAR(100), ''Execution - Completed'')
)
'
GO
