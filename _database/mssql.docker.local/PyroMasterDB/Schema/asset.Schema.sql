IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'asset')
EXEC sys.sp_executesql N'CREATE SCHEMA [asset]'
GO
