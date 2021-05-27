IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'depend')
EXEC sys.sp_executesql N'CREATE SCHEMA [depend]'
GO
