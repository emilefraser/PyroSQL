SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[LogErrorMessageAndRaiseError]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[LogErrorMessageAndRaiseError] AS' 
END
GO


-- =======================================================================
-- PROCEDURE: LogErrorMessageAndRaiseError
-- Called by some other TST infrastructure procedures to log an 
-- error message and raise a TST error.
-- =======================================================================
ALTER   PROCEDURE [internal].[LogErrorMessageAndRaiseError]
   @ErrorMessage  nvarchar(max)
AS
BEGIN
   EXEC Internal.LogErrorMessage @ErrorMessage
   RAISERROR('TST RAISERROR {6C57D85A-CE44-49ba-9286-A5227961DF02}', 16, 110)
END
GO
