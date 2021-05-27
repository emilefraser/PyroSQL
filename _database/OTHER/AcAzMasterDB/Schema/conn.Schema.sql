IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'conn')
EXEC sys.sp_executesql N'CREATE SCHEMA [conn]'
GO
