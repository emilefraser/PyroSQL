SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[ClearExpectedError]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[ClearExpectedError] AS' 
END
GO

-- =======================================================================
-- PROCEDURE: ClearExpectedError
-- Clear the info about the expected error.
-- =======================================================================
ALTER   PROCEDURE [internal].[ClearExpectedError]
AS
BEGIN
   UPDATE #Tmp_CrtSessionInfo SET 
      ExpectedErrorNumber          = NULL,
      ExpectedErrorMessage         = NULL, 
      ExpectedErrorProcedure       = NULL,
      ExpectedErrorContextMessage  = NULL
END
GO
