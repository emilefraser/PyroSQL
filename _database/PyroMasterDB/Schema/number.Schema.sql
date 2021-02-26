IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'number')
EXEC sys.sp_executesql N'CREATE SCHEMA [number]'
GO
