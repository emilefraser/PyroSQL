IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'reference')
EXEC sys.sp_executesql N'CREATE SCHEMA [reference]'
GO
