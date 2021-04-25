SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[RunSessionLevelSProc]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[RunSessionLevelSProc] AS' 
END
GO

-- =======================================================================
-- PROCEDURE RunSessionLevelSProc
-- This will run the given TST test procedure and pass it the 
-- parameter '@TestSessionId'.
-- =======================================================================
ALTER   PROCEDURE [internal].[RunSessionLevelSProc]
   @TestSessionId       int,        -- Identifies the test session.
   @TestId              int         -- Identifies the test.
AS
BEGIN
   DECLARE @SqlCommand     nvarchar(1000)
   SET @SqlCommand = 'EXEC ' + Internal.SFN_GetFullSprocName(@TestId) + ' ' + CAST(@TestSessionId AS varchar)
   EXEC sp_executesql @SqlCommand
END
GO
