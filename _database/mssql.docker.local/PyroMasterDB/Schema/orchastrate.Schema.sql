IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'orchastrate')
EXEC sys.sp_executesql N'CREATE SCHEMA [orchastrate]'
GO
