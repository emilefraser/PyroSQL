IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'logger')
EXEC sys.sp_executesql N'CREATE SCHEMA [logger]'
GO
