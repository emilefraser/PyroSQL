IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Generator')
EXEC sys.sp_executesql N'CREATE SCHEMA [Generator]'
GO
