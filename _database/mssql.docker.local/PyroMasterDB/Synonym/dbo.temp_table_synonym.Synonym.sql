IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'temp_table_synonym' AND schema_id = SCHEMA_ID(N'dbo'))
CREATE SYNONYM [dbo].[temp_table_synonym] FOR [#temp]
GO
