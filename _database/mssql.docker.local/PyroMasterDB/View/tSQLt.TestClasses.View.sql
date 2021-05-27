SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[tSQLt].[TestClasses]'))
EXEC dbo.sp_executesql @statement = N'
----------------------------------------------------------------------
CREATE VIEW [tSQLt].[TestClasses]
AS
  SELECT s.name AS Name, s.schema_id AS SchemaId
    FROM sys.extended_properties ep
    JOIN sys.schemas s
      ON ep.major_id = s.schema_id
   WHERE ep.name = N''tSQLt.TestClass'';
' 
GO
