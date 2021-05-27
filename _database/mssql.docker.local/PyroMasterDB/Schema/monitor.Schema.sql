IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'monitor')
EXEC sys.sp_executesql N'CREATE SCHEMA [monitor]'
GO
