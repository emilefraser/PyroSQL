IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'string')
EXEC sys.sp_executesql N'CREATE SCHEMA [string]'
GO
