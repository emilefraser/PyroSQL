IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'arm')
EXEC sys.sp_executesql N'CREATE SCHEMA [arm]'
GO
