IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'schedule')
EXEC sys.sp_executesql N'CREATE SCHEMA [schedule]'
GO
