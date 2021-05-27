IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'hierarchy')
EXEC sys.sp_executesql N'CREATE SCHEMA [hierarchy]'
GO
