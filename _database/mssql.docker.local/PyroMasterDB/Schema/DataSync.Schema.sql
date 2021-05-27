IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'DataSync')
EXEC sys.sp_executesql N'CREATE SCHEMA [DataSync]'
GO
