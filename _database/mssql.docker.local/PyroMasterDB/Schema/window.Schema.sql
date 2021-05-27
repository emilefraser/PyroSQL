IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'window')
EXEC sys.sp_executesql N'CREATE SCHEMA [window]'
GO
