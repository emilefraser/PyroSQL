SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =======================================================================
-- PROCEDURE: LogErrorMessageAndRaiseError
-- Called by some other TST infrastructure procedures to log an 
-- error message and raise a TST error.
-- =======================================================================
CREATE PROCEDURE Internal.LogErrorMessageAndRaiseError
   @ErrorMessage  nvarchar(max)
AS
BEGIN
   EXEC Internal.LogErrorMessage @ErrorMessage
   RAISERROR('TST RAISERROR {6C57D85A-CE44-49ba-9286-A5227961DF02}', 16, 110)
END

GO
