IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'printer')
EXEC sys.sp_executesql N'CREATE SCHEMA [printer]'
GO
