IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'azure')
EXEC sys.sp_executesql N'CREATE SCHEMA [azure]'
GO
