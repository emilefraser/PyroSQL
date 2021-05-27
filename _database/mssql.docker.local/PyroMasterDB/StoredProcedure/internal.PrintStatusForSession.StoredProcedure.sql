SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[PrintStatusForSession]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[PrintStatusForSession] AS' 
END
GO

-- =======================================================================
-- PROCEDURE: PrintStatusForSession
-- See the coments at the begining of the file under section 'Results Format'
-- This procedure will print the results when the @ResultsFormat = 'Batch'
-- =======================================================================
ALTER   PROCEDURE [internal].[PrintStatusForSession]
   @TestSessionId    int      -- Identifies the test session.
AS
BEGIN

   DECLARE @TestSessionStatus bit
   SET @TestSessionStatus = Internal.SFN_GetSessionStatus(@TestSessionId) 

   IF (@TestSessionStatus = 1) PRINT 'TST Status: Passed'
   ELSE PRINT 'TST Status: Failed'

END
GO
