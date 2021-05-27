IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'runner')
EXEC sys.sp_executesql N'CREATE SCHEMA [runner]'
GO
