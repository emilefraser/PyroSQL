IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'config')
EXEC sys.sp_executesql N'CREATE SCHEMA [config]'
GO
