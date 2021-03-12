IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'test')
EXEC sys.sp_executesql N'CREATE SCHEMA [test]'
GO
