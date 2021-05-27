SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[GetCurrentTestSessionId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[GetCurrentTestSessionId] AS' 
END
GO

-- =======================================================================
-- PROCEDURE GetCurrentTestSessionId
-- Returns in @TestSessionId the test session id for the current
-- test session.
-- =======================================================================
ALTER   PROCEDURE [internal].[GetCurrentTestSessionId]
   @TestSessionId int OUT
AS
BEGIN

   SELECT @TestSessionId = TestSessionId FROM #Tmp_CrtSessionInfo
   
END
GO
