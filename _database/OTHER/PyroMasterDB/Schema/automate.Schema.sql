IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'automate')
EXEC sys.sp_executesql N'CREATE SCHEMA [automate]'
GO
