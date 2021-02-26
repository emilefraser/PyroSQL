IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dataprofile')
EXEC sys.sp_executesql N'CREATE SCHEMA [dataprofile]'
GO
