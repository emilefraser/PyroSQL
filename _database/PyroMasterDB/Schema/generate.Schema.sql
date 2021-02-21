IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'generate')
EXEC sys.sp_executesql N'CREATE SCHEMA [generate]'
GO
