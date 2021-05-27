IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'secure')
EXEC sys.sp_executesql N'CREATE SCHEMA [secure]'
GO
