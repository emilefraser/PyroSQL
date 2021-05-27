IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'connect')
EXEC sys.sp_executesql N'CREATE SCHEMA [connect]'
GO
