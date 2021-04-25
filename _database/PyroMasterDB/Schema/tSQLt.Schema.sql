IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'tSQLt')
EXEC sys.sp_executesql N'CREATE SCHEMA [tSQLt]'
GO
