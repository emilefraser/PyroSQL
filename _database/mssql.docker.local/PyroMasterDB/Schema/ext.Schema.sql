IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'ext')
EXEC sys.sp_executesql N'CREATE SCHEMA [ext]'
GO
