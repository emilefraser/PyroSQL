IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'procfwk')
EXEC sys.sp_executesql N'CREATE SCHEMA [procfwk]'
GO
GRANT EXECUTE ON SCHEMA::[procfwk] TO [adf_procfwkuser] AS [dbo]
GO
GRANT SELECT ON SCHEMA::[procfwk] TO [adf_procfwkuser] AS [dbo]
GO
GRANT EXECUTE ON SCHEMA::[procfwk] TO [adf_serviceuser] AS [dbo]
GO
GRANT SELECT ON SCHEMA::[procfwk] TO [adf_serviceuser] AS [dbo]
GO
GRANT SELECT ON SCHEMA::[procfwk] TO [frasere] WITH GRANT OPTION  AS [dbo]
GO
