SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE RunSessionLevelSProc
-- This will run the given TST test procedure and pass it the 
-- parameter '@TestSessionId'.
-- =======================================================================
CREATE PROCEDURE Internal.RunSessionLevelSProc
   @TestSessionId       int,        -- Identifies the test session.
   @TestId              int         -- Identifies the test.
AS
BEGIN
   DECLARE @SqlCommand     nvarchar(1000)
   SET @SqlCommand = 'EXEC ' + Internal.SFN_GetFullSprocName(@TestId) + ' ' + CAST(@TestSessionId AS varchar)
   EXEC sp_executesql @SqlCommand
END

GO
