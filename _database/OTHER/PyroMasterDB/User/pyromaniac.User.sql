IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'pyromaniac')
CREATE USER [pyromaniac] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
