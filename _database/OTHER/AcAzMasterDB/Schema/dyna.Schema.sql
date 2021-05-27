IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dyna')
EXEC sys.sp_executesql N'CREATE SCHEMA [dyna]'
GO
