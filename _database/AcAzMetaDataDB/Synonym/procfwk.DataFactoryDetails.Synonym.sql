IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'DataFactoryDetails' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[DataFactoryDetails] FOR [procfwk].[DataFactorys]
GO
