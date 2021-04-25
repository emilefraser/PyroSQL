IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'resurse')
EXEC sys.sp_executesql N'CREATE SCHEMA [resurse]'
GO
