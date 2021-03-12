IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'compare')
EXEC sys.sp_executesql N'CREATE SCHEMA [compare]'
GO
