IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'masterdb')
EXEC sys.sp_executesql N'CREATE SCHEMA [masterdb]'
GO
