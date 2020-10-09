SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE [tSQLt].[AssertResultSetsHaveSameMetaData]
	@expectedCommand [nvarchar](max),
	@actualCommand [nvarchar](max)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [tSQLtCLR].[tSQLtCLR.StoredProcedures].[AssertResultSetsHaveSameMetaData]
GO
