IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'AcceleratorTests')
EXEC sys.sp_executesql N'CREATE SCHEMA [AcceleratorTests]'
GO
IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'tSQLt.TestClass' , N'SCHEMA',N'AcceleratorTests', NULL,NULL, NULL,NULL))
	EXEC sys.sp_addextendedproperty @name=N'tSQLt.TestClass', @value=1 , @level0type=N'SCHEMA',@level0name=N'AcceleratorTests'
GO
