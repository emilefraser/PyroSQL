SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[CaptureOutput]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[CaptureOutput] AS' 
END
GO
ALTER PROCEDURE [tSQLt].[CaptureOutput]
	@command [nvarchar](max)
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [tSQLtCLR].[tSQLtCLR.StoredProcedures].[CaptureOutput]
GO
