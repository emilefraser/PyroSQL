SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_InputBuffer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Private_InputBuffer] AS' 
END
GO
ALTER PROCEDURE [tSQLt].[Private_InputBuffer]
  @InputBuffer NVARCHAR(MAX) OUTPUT
AS
BEGIN
  CREATE TABLE #inputbuffer(EventType SYSNAME, Parameters SMALLINT, EventInfo NVARCHAR(MAX));
  INSERT INTO #inputbuffer
  EXEC('DBCC INPUTBUFFER(@@SPID) WITH NO_INFOMSGS;');
  SELECT @InputBuffer = I.EventInfo FROM #inputbuffer AS I;
END;
GO
