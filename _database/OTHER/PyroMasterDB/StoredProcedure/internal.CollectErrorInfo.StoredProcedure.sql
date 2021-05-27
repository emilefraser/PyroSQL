SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[CollectErrorInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[CollectErrorInfo] AS' 
END
GO

-- =======================================================================
-- PROCEDURE CollectErrorInfo
-- Called from within inside a CATCH block. It processes the information 
-- in the ERROR_XXX functions. It examines XACT_STATE() and 
-- @@TRANCOUNT and based on all that it will return an error code.
-- Return code:
--    0 - This was an expected error as recorded by RegisterExpectedError.
--        No transaction was rolled back. The transaction if open is in 
--        a committable state. 
--    1 - Failure. Assert failure as oposed to an error. 
--    2 - Error. The test failed with an error. The transaction if open 
--               is in a committable state. The error was recorded and 
--               @ErrorMessage will be NULL.
--    3 - Error. The test failed with an error. The transaction is in an 
--               uncommittable state. @ErrorMessage will contain the error 
--               text. 
--    4 - Error. The transaction was rolled back. Normally this is acompanied 
--               by a 266 or 3609 error:
--                226: Transaction count after EXECUTE indicates that a COMMIT or ROLLBACK TRAN is missing
--               3609: The transaction ended in the trigger.
--               The error was recorded and @ErrorMessage will be NULL.
--    5 - This was an expected error as recorded by RegisterExpectedError.
--        No transaction was rolled back. However the transaction is in 
--        an uncommittable state. 
-- =======================================================================
ALTER   PROCEDURE [internal].[CollectErrorInfo]
   @TestId                       int,                -- Identifies the test where the error occured.
   @UseTSTRollback               bit,                -- 1 if TSTRollback is enabled.
   @StartTranCount               int,                -- The transaction count before the setup procedure was invoked.
   @ErrorMessage                 nvarchar(max) OUT,  -- If an error occured it will contain the error text
   @NestedTransactionMessage     nvarchar(max) OUT   -- If a nested transaction caused issues this will have an error message regarding that.
AS 
BEGIN

   DECLARE @TSTRollbackMessage         nvarchar(4000)
   DECLARE @InProcedureMsg             nvarchar(100)
   DECLARE @FullSprocName              nvarchar(1000)

   DECLARE @Catch_ErrorMessage   nvarchar(2048) 
   DECLARE @Catch_ErrorProcedure nvarchar(126)
   DECLARE @Catch_ErrorLine      int
   DECLARE @Catch_ErrorNumber    int

   DECLARE @ExpectedErrorNumber       int
   DECLARE @ExpectedErrorMessage      nvarchar(2048) 
   DECLARE @ExpectedErrorProcedure    nvarchar(126)
   DECLARE @IsExpectedError           bit

   SET @Catch_ErrorMessage   = ERROR_MESSAGE()
   SET @Catch_ErrorProcedure = ERROR_PROCEDURE()
   SET @Catch_ErrorLine      = ERROR_LINE()
   SET @Catch_ErrorNumber    = ERROR_NUMBER()

   -- If this is an error raised by the TST API (like Assert) we don't have to log the error, it was already logged.
   IF (@Catch_ErrorMessage = 'TST RAISERROR {6C57D85A-CE44-49ba-9286-A5227961DF02}') RETURN 1

   -- Check if this is an expected error.
   SET @IsExpectedError = 0
   SELECT 
      @ExpectedErrorNumber       = ExpectedErrorNumber    ,
      @ExpectedErrorMessage      = ExpectedErrorMessage   ,
      @ExpectedErrorProcedure    = ExpectedErrorProcedure 
   FROM #Tmp_CrtSessionInfo
   
   IF ( (@ExpectedErrorNumber IS NOT NULL) OR (@ExpectedErrorMessage IS NOT NULL) OR (@ExpectedErrorProcedure IS NOT NULL) )
   BEGIN
      IF (      (@Catch_ErrorNumber    = @ExpectedErrorNumber    OR @ExpectedErrorNumber IS NULL      )
            AND (@Catch_ErrorMessage   = @ExpectedErrorMessage   OR @ExpectedErrorMessage IS NULL     )
            AND (@Catch_ErrorProcedure = @ExpectedErrorProcedure OR @ExpectedErrorProcedure IS NULL   ) )
      BEGIN
         SET @IsExpectedError = 1
      END
   END
      
   IF (@UseTSTRollback = 1)
   BEGIN
      IF (@Catch_ErrorNumber = 266 OR @Catch_ErrorNumber = 3609 OR @@TRANCOUNT != @StartTranCount)
      BEGIN
      
         SET @TSTRollbackMessage = 'To disable TST rollback create a stored procedure called TSTConfig in the database where you ' +
                        'have the test procedures. Inside TSTConfig call ' + 
                        '<EXEC TST.Utils.SetConfiguration @ParameterName=''UseTSTRollback'', @ParameterValue=''0'' @Scope=''Test'', @ScopeValue=''_name_of_test_procedure_''>. ' + 
                        'Warning: When you disable TST rollback, TST framework will not rollback the canges made by SETUP, test and TEARDOWN procedures. ' + 
                        'See TST documentation for more details.'

         IF (@Catch_ErrorProcedure IS NULL) SET @InProcedureMsg = ''
         ELSE SET @InProcedureMsg = ' in procedure ''' + @Catch_ErrorProcedure + ''''

         IF (@Catch_ErrorNumber = 266 OR @@TRANCOUNT != @StartTranCount)
         BEGIN
            IF (@@TRANCOUNT > 0)
            BEGIN
               SET @NestedTransactionMessage =  'BEGIN TRANSACTION with no matching COMMIT detected' + 
                                    @InProcedureMsg + '. ' + 
                                    'Please disable the TST rollback if you expect the tested procedure to use BEGIN TRANSACTION with no matching COMMIT. ' + 
                                    @TSTRollbackMessage
            END
            ELSE
            BEGIN
               SET @NestedTransactionMessage =  'ROLLBACK TRANSACTION detected' + 
                                    @InProcedureMsg + '. ' + 
                                    'All other TST messages logged during this test and previous to this error were lost. ' + 
                                    'Please disable the TST rollback if you expect the tested procedure to use ROLLBACK TRANSACTION. ' + 
                                    @TSTRollbackMessage
            END
         END
         ELSE
         BEGIN
            IF (@@TRANCOUNT > 0)
            BEGIN
               SET @NestedTransactionMessage =  'BEGIN TRANSACTION with no matching COMMIT detected during trigger execution' + 
                                    @InProcedureMsg + '. ' + 
                                    'This looks like a bug in the trigger and you should consider fixing that. ' + 
                                    'Alternatively you can disable the TST rollback if you expect the trigger to use BEGIN TRANSACTION with no matching COMMIT. ' + 
                                    @TSTRollbackMessage
            END
            ELSE
            BEGIN
               SET @NestedTransactionMessage =  'ROLLBACK TRANSACTION detected during trigger execution' + 
                                    @InProcedureMsg + '. ' + 
                                    'Please disable the TST rollback if you expect the trigger to use ROLLBACK TRANSACTION. ' + 
                                    @TSTRollbackMessage
            END
         END
      END
   END
      
   IF (@IsExpectedError = 1)
   BEGIN
      IF (XACT_STATE() = -1)  RETURN 5    -- Expected error but the transaction is in a uncommittable state.
      IF (@@TRANCOUNT != @StartTranCount AND @@TRANCOUNT = 0) RETURN 4
      RETURN 0
   END
   ELSE
   BEGIN
      SET @FullSprocName = Internal.SFN_GetFullSprocName(@TestId)
      SET @ErrorMessage =  'An error occured during the execution of the test procedure ''' + @FullSprocName + 
                           '''. Error: ' + CAST(ERROR_NUMBER() AS varchar) + ', ' + ERROR_MESSAGE() + 
                           ' Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A') + '. Line: ' + CAST(ERROR_LINE() AS varchar)

      IF (XACT_STATE() = -1)  RETURN 3    -- The transaction is in a uncommittable state.

      IF (@IsExpectedError = 0) 
      BEGIN
         
         IF (@ErrorMessage IS NOT NULL)               
         BEGIN
            EXEC Internal.LogErrorMessage @ErrorMessage; SET @ErrorMessage = NULL
         END
         
         IF (@NestedTransactionMessage IS NOT NULL)   
         BEGIN
            EXEC Internal.LogErrorMessage @NestedTransactionMessage; SET @NestedTransactionMessage = NULL
         END
         
      END

      IF (@@TRANCOUNT != @StartTranCount AND @@TRANCOUNT = 0) RETURN 4
      RETURN 2
   END
   
END
GO
