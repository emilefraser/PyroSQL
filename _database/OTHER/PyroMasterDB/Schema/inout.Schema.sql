IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'inout')
EXEC sys.sp_executesql N'CREATE SCHEMA [inout]'
GO
