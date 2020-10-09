SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE [tSQLt].[ResultSetFilter]
	@ResultsetNo [int],
	@Command [nvarchar](max)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [tSQLtCLR].[tSQLtCLR.StoredProcedures].[ResultSetFilter]
GO
