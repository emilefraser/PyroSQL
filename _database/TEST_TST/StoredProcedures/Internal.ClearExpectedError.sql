SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: ClearExpectedError
-- Clear the info about the expected error.
-- =======================================================================
CREATE PROCEDURE Internal.ClearExpectedError
AS
BEGIN
   UPDATE #Tmp_CrtSessionInfo SET 
      ExpectedErrorNumber          = NULL,
      ExpectedErrorMessage         = NULL, 
      ExpectedErrorProcedure       = NULL,
      ExpectedErrorContextMessage  = NULL
END

GO
