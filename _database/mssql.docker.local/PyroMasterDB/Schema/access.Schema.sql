IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'access')
EXEC sys.sp_executesql N'CREATE SCHEMA [access]'
GO
