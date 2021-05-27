IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'initialize')
EXEC sys.sp_executesql N'CREATE SCHEMA [initialize]'
GO
