IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'help')
EXEC sys.sp_executesql N'CREATE SCHEMA [help]'
GO
