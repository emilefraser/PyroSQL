IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'stat')
EXEC sys.sp_executesql N'CREATE SCHEMA [stat]'
GO
