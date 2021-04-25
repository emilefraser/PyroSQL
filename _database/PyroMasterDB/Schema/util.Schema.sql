IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'util')
EXEC sys.sp_executesql N'CREATE SCHEMA [util]'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'Description' , N'SCHEMA',N'util', NULL,NULL, NULL,NULL))
	EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Generic utility data and functions' , @level0type=N'SCHEMA',@level0name=N'util'
GO
