IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'struct')
EXEC sys.sp_executesql N'CREATE SCHEMA [struct]'
GO
