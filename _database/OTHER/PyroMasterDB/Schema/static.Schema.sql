IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'static')
EXEC sys.sp_executesql N'CREATE SCHEMA [static]'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Description' , N'SCHEMA',N'static', NULL,NULL, NULL,NULL))
	EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Static betl data, not dependent on customer implementation' , @level0type=N'SCHEMA',@level0name=N'static'
GO
