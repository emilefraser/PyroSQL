IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'recurse')
EXEC sys.sp_executesql N'CREATE SCHEMA [recurse]'
GO
