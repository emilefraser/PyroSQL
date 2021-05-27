IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'balance')
EXEC sys.sp_executesql N'CREATE SCHEMA [balance]'
GO
