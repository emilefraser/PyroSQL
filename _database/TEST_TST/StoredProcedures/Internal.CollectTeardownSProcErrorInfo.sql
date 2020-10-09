SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE CollectTeardownSProcErrorInfo
-- Called from within inside a CATCH block. It processes the information 
-- in the ERROR_XXX functions. It examines XACT_STATE() and 
-- @@TRANCOUNT and based on all that it will return an error code.
-- If the active transaction is in an uncommitable state it will do a 
-- ROLLBACK while preserving the entries in the TestLog table.
-- Return code: 1
-- =======================================================================
CREATE PROCEDURE Internal.CollectTeardownSProcErrorInfo
   @TestSessionId                int,              -- Identifies the test session.
   @TeardownSProcId              int,              -- Identifies the teardown proc where the error occured.
   @UseTSTRollback               bit,              -- 1 if TSTRollback is enabled.
   @StartTranCount               int,              -- The transaction count before the setup procedure was invoked.
   @LastTestLogEntryIdBeforeTest int               -- The last id that was present in the TestLog 
                                                   -- table before the test execution started.
AS
BEGIN

   DECLARE @ErrorCode                     int
   DECLARE @ReturnCode                    int
   DECLARE @FullSprocName                 nvarchar(1000)
   DECLARE @ErrorMessage                  nvarchar(max)  -- If an error occured it will contain the error text
   DECLARE @NestedTransactionMessage      nvarchar(max)  -- If a nested transaction caused issues this will have an error message regarding that.
   DECLARE @TransactionWarningMessage     nvarchar(max)  -- If the teardown will have to be invoked outside of the context of a transaction 
                                                         -- this will have an error message regarding that.

   SET @ReturnCode = -1

   EXEC @ErrorCode = Internal.CollectErrorInfo  
                           @TeardownSProcId, 
                           @StartTranCount, 
                           @UseTSTRollback, 
                           @ErrorMessage OUT,
                           @NestedTransactionMessage OUT

   -- We do not allow "Expected errors" during the Teardown.
   -- If during the Teardown we get an "Expected errors" we will record an error.
   IF (@ErrorCode = 0) SET @ErrorCode = 2
   IF (@ErrorCode = 5) SET @ErrorCode = 2

   IF      (@UseTSTRollback = 1 AND @ErrorCode = 1)  SET @ReturnCode = 1
   ELSE IF (@UseTSTRollback = 1 AND @ErrorCode = 2)  SET @ReturnCode = 1
   ELSE IF (@UseTSTRollback = 1 AND @ErrorCode = 3)   
   BEGIN
      -- The transaction is in an invalid (uncomittable) state. We need to roll it back.
      SET @FullSprocName = Internal.SFN_GetFullSprocName(@TeardownSProcId)
      SET @TransactionWarningMessage = 'The transaction is in an uncommitable state after the teardown procedure ''' + @FullSprocName + ''' has failed. A rollback was forced.'
      SET @ReturnCode = 1
      
      GOTO LblSaveLogAndRollback
   END
   ELSE IF (@UseTSTRollback = 1 AND @ErrorCode = 4)   
   BEGIN
      SET @FullSprocName = Internal.SFN_GetFullSprocName(@TeardownSProcId)
      SET @TransactionWarningMessage = 'The transaction was rolled back during the teardown procedure ''' + @FullSprocName + '''.'
      SET @ReturnCode = 1
   END
   ELSE IF (@UseTSTRollback = 0 AND @ErrorCode = 1)  SET @ReturnCode = 1
   ELSE IF (@UseTSTRollback = 0 AND @ErrorCode = 2)  SET @ReturnCode = 1
   IF (@UseTSTRollback = 0 AND @ErrorCode = 3)   
   BEGIN
      -- If we did not begin a transaction but now we have a transaction in an uncommitable state 
      -- then it means that the client opened it. We will rollback the transaction.
      SET @FullSprocName = Internal.SFN_GetFullSprocName(@TeardownSProcId)
      SET @TransactionWarningMessage = 'The teardown procedure ''' + @FullSprocName + ''' opened a transaction that is now in an uncommitable state. A rollback was forced.'
      SET @ReturnCode = 1
      
      GOTO LblSaveLogAndRollback
   END
   -- ELSE IF (@UseTSTRollback = 0 AND @ErrorCode = 4) This cannot happen. We will live @ReturnCode set to -1 which will generate an internal error

   GOTO LblSaveErrors

LblSaveLogAndRollback:

   BEGIN TRY
      -- Rollback and in the same time preserves the log entries
      EXEC Internal.RollbackWithLogPreservation @TestSessionId, @LastTestLogEntryIdBeforeTest
   END TRY
   BEGIN CATCH
      -- RollbackWithLogPreservation will execute a ROLLBACK transaction so an error 266 caused by @@Trancount mismatch is expected. 
      IF (ERROR_NUMBER() != 266) EXEC Internal.Rethrow
   END CATCH

LblSaveErrors:

   IF (@ErrorMessage                 IS NOT NULL)  EXEC Internal.LogErrorMessage @ErrorMessage
   IF (@NestedTransactionMessage     IS NOT NULL)  EXEC Internal.LogErrorMessage @NestedTransactionMessage
   IF (@TransactionWarningMessage    IS NOT NULL)  EXEC Internal.LogErrorMessage @TransactionWarningMessage

   IF (@ReturnCode < 0)
   BEGIN 
      EXEC Internal.LogErrorMessage 'TST Internal Error in CollectTeardownSProcErrorInfo. Unexpected error code'
      SET @ReturnCode = 1
   END

   RETURN @ReturnCode

END

GO
