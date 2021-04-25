IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'moto_mktg')
EXEC sys.sp_executesql N'CREATE SCHEMA [moto_mktg]'
GO
