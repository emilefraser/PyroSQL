IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'meta')
EXEC sys.sp_executesql N'CREATE SCHEMA [meta]'
GO
