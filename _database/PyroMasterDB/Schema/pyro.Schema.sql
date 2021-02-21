IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'pyro')
EXEC sys.sp_executesql N'CREATE SCHEMA [pyro]'
GO
