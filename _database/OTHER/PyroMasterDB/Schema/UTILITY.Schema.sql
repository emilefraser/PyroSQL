IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'UTILITY')
EXEC sys.sp_executesql N'CREATE SCHEMA [UTILITY]'
GO
