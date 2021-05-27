IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'bprac')
EXEC sys.sp_executesql N'CREATE SCHEMA [bprac]'
GO
