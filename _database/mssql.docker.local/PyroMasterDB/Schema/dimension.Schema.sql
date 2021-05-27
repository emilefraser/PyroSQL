IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dimension')
EXEC sys.sp_executesql N'CREATE SCHEMA [dimension]'
GO
