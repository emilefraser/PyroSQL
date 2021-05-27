IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'TaskHosting')
EXEC sys.sp_executesql N'CREATE SCHEMA [TaskHosting]'
GO
GRANT CONTROL ON SCHEMA::[TaskHosting] TO [DataSync_admin] AS [##MS_SyncAccount##]
GO
GRANT EXECUTE ON SCHEMA::[TaskHosting] TO [DataSync_executor] AS [##MS_SyncAccount##]
GO
GRANT SELECT ON SCHEMA::[TaskHosting] TO [DataSync_executor] AS [##MS_SyncAccount##]
GO
GRANT SELECT ON SCHEMA::[TaskHosting] TO [DataSync_reader] AS [##MS_SyncAccount##]
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_name' , N'SCHEMA',N'TaskHosting', NULL,NULL, NULL,NULL))
	EXEC sys.sp_addextendedproperty @name=N'MS_name', @value=N'DataSync' , @level0type=N'SCHEMA',@level0name=N'TaskHosting'
GO
