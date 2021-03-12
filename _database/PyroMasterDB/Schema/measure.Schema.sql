IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'measure')
EXEC sys.sp_executesql N'CREATE SCHEMA [measure]'
GO
