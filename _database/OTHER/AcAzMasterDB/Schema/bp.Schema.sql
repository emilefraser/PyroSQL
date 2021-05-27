IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'bp')
EXEC sys.sp_executesql N'CREATE SCHEMA [bp]'
GO
