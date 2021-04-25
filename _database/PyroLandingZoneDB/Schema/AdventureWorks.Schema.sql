IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'AdventureWorks')
EXEC sys.sp_executesql N'CREATE SCHEMA [AdventureWorks]'
GO
