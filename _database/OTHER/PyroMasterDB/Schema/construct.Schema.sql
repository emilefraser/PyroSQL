IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'construct')
EXEC sys.sp_executesql N'CREATE SCHEMA [construct]'
GO
