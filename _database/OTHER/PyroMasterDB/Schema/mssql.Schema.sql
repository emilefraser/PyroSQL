IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'mssql')
EXEC sys.sp_executesql N'CREATE SCHEMA [mssql]'
GO
