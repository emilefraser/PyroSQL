IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'kevro')
EXEC sys.sp_executesql N'CREATE SCHEMA [kevro]'
GO
