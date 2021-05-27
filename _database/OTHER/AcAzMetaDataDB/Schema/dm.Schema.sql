IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dm')
EXEC sys.sp_executesql N'CREATE SCHEMA [dm]'
GO
