IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dss')
EXEC sys.sp_executesql N'CREATE SCHEMA [dss]'
GO
GRANT CONTROL ON SCHEMA::[dss] TO [DataSync_admin] AS [##MS_SyncAccount##]
GO
GRANT EXECUTE ON SCHEMA::[dss] TO [DataSync_executor] AS [##MS_SyncAccount##]
GO
GRANT SELECT ON SCHEMA::[dss] TO [DataSync_executor] AS [##MS_SyncAccount##]
GO
GRANT SELECT ON SCHEMA::[dss] TO [DataSync_reader] AS [##MS_SyncAccount##]
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_name' , N'SCHEMA',N'dss', NULL,NULL, NULL,NULL))
	EXEC sys.sp_addextendedproperty @name=N'MS_name', @value=N'DataSync' , @level0type=N'SCHEMA',@level0name=N'dss'
GO
