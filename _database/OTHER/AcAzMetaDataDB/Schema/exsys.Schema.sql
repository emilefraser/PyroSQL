IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'exsys')
EXEC sys.sp_executesql N'CREATE SCHEMA [exsys]'
GO
