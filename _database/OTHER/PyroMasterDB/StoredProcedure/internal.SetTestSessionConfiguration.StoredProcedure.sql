SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[SetTestSessionConfiguration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[SetTestSessionConfiguration] AS' 
END
GO

-- =======================================================================
-- PROCEDURE SetTestSessionConfiguration
-- It searches for a stored procedure called TSTConfig in the tested 
-- database. If it exists it calls it. This allow tests to configure 
-- TST before proceeding with the test session.
--    0 - OK.
--    1 - An error was detected during the execution of TSTConfig.
--        In case of an error an error message is stored in one of the log tables.
-- =======================================================================
ALTER   PROCEDURE [internal].[SetTestSessionConfiguration]
   @TestSessionId       int            -- Identifies the test session
AS
BEGIN

   DECLARE @SqlCommand        nvarchar(1000)
   DECLARE @TestDatabaseName  sysname
   DECLARE @PrepareResult     bit
   DECLARE @ErrorMessage      nvarchar(4000)   
   
   SET @PrepareResult = 0
   
   SELECT @TestDatabaseName = TestSession.DatabaseName FROM Data.TestSession WHERE TestSessionId = @TestSessionId

   IF (Internal.SFN_SProcExists(@TestDatabaseName, 'TSTConfig') = 1)
   BEGIN
      SET @SqlCommand = QUOTENAME(@TestDatabaseName) + '..' + QUOTENAME('TSTConfig')
      
      BEGIN TRY
         EXEC @SqlCommand
      END TRY
      BEGIN CATCH
         SET @ErrorMessage =  'An error occured during the execution of the TSTConfig procedure.' +
                              ' Error: ' + CAST(ERROR_NUMBER() AS varchar) + ', ' + ERROR_MESSAGE() + 
                              ' Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A') + '. Line: ' + CAST(ERROR_LINE() AS varchar)
         EXEC Internal.LogErrorMessage @ErrorMessage
         
         SET @PrepareResult = 1
      END CATCH

   END

   RETURN @PrepareResult
END
GO
