IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'adf')
EXEC sys.sp_executesql N'CREATE SCHEMA [adf]'
GO
GRANT SELECT ON SCHEMA::[adf] TO [frasere] WITH GRANT OPTION  AS [emilefraser]
GO
