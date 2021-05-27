IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'productivity')
EXEC sys.sp_executesql N'CREATE SCHEMA [productivity]'
GO
