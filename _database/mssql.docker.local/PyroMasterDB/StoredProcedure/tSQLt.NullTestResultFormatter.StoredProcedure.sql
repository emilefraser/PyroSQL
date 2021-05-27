SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[NullTestResultFormatter]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[NullTestResultFormatter] AS' 
END
GO

ALTER PROCEDURE [tSQLt].[NullTestResultFormatter]
AS
BEGIN
  RETURN 0;
END;
GO
