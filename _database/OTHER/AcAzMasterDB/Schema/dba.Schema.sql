IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dba')
EXEC sys.sp_executesql N'CREATE SCHEMA [dba]'
GO
