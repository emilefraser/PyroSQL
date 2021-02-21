IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'init')
EXEC sys.sp_executesql N'CREATE SCHEMA [init]'
GO
