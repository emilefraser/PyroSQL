IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'benchmark')
EXEC sys.sp_executesql N'CREATE SCHEMA [benchmark]'
GO
