IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'materialize')
EXEC sys.sp_executesql N'CREATE SCHEMA [materialize]'
GO
