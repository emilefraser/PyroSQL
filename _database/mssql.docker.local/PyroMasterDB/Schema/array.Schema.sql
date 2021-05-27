IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'array')
EXEC sys.sp_executesql N'CREATE SCHEMA [array]'
GO
