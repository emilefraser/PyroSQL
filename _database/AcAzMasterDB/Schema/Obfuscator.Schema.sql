IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Obfuscator')
EXEC sys.sp_executesql N'CREATE SCHEMA [Obfuscator]'
GO
