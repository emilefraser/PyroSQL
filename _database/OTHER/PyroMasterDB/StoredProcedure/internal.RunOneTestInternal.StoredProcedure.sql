SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[RunOneTestInternal]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[RunOneTestInternal] AS' 
END
GO


-- =======================================================================
-- PROCEDURE RunOneTestInternal
-- Runs a given test including its suite and teardown if defined. 
-- Implements the TST Rollback: will run the test in the context of a 
-- transaction that will be reverted at the end.
-- Note: The TST Rollback can be disabled.
-- =======================================================================
ALTER   PROCEDURE [internal].[RunOneTestInternal]
   @TestSessionId    int,     -- Identifies the test session.
   @TestSProcId      int,     -- Identifies the test stored procedure.
   @SetupSProcId     int,     -- Identifies the setup stored procedure.
   @TeardownSProcId  int      -- Identifies the teardown stored procedure.
AS
BEGIN

   DECLARE @LastTestLogEntryIdBeforeTest  int
   DECLARE @UseTSTRollback                bit
   DECLARE @UseTeardown                   bit
   DECLARE @SetupSprocErrorCode           int
   DECLARE @TestSprocErrorCode            int
   DECLARE @TeardownSprocErrorCode        int

   DECLARE @ExpectedErrorContextMessage   nvarchar(1000)
   DECLARE @ExpectedErrorInfo             nvarchar(4000)
   DECLARE @FullSprocName                 nvarchar(1000)
   DECLARE @Message                       nvarchar(max)
   DECLARE @StartTranCount                int


   UPDATE #Tmp_CrtSessionInfo SET TestId = @TestSProcId
   EXEC Internal.ClearExpectedError

   -- EXEC Utils.DropTestTables

   SET @UseTSTRollback = Internal.SFN_UseTSTRollbackForTest(@TestSessionId, @TestSProcId)
   IF (@UseTSTRollback = 1)
   BEGIN
      BEGIN TRANSACTION 
   END

   SET @UseTeardown = 0
   IF (@TeardownSProcId IS NOT NULL)
   BEGIN
      SET @UseTeardown = 1
   END

   SET @StartTranCount = @@TRANCOUNT
   
   SELECT @LastTestLogEntryIdBeforeTest = LogEntryId FROM Data.TestLog WHERE TestSessionId = @TestSessionId
   SET @LastTestLogEntryIdBeforeTest = ISNULL(@LastTestLogEntryIdBeforeTest, 0)

   --================================
   -- SETUP
   --================================
   IF (@SetupSProcId IS NOT NULL) 
   BEGIN TRY
      UPDATE #Tmp_CrtSessionInfo SET Stage = 'S'
      EXEC Internal.RunOneSProc @SetupSProcId
   END TRY
   BEGIN CATCH
      BEGIN TRY
         EXEC @SetupSprocErrorCode = Internal.CollectSetupSProcErrorInfo
                                          @TestSessionId                 = @TestSessionId,
                                          @SetupSProcId                  = @SetupSProcId,
                                          @UseTSTRollback                = @UseTSTRollback,
                                          @StartTranCount                = @StartTranCount,
                                          @LastTestLogEntryIdBeforeTest  = @LastTestLogEntryIdBeforeTest
      END TRY
      BEGIN CATCH
         -- Some scenarios may cause CollectSetupSProcErrorInfo to rollback transactions. 
         -- When that happens the @@TRANCOUNT mismatch will trigger an error with error number 266. We'll ignore that error here.
         IF (ERROR_NUMBER() != 266) EXEC Internal.Rethrow
      END CATCH
      
      IF (@SetupSprocErrorCode = 0) GOTO LblBeforeTest
      IF (@SetupSprocErrorCode = 1) GOTO LblBeforeTeardown
      IF (@SetupSprocErrorCode = 2) GOTO LblPostTest

   END CATCH

LblBeforeTest:

   --================================
   -- TEST
   --================================
   BEGIN TRY
      UPDATE #Tmp_CrtSessionInfo SET Stage = 'T'
      EXEC Internal.RunOneSProc @TestSProcId

      -- Check if we were supposed to get an error.
      EXEC Internal.GetExpectedErrorInfo @ExpectedErrorContextMessage OUT, @ExpectedErrorInfo OUT 
      IF( @ExpectedErrorContextMessage IS NOT NULL)
      BEGIN
         SET @FullSprocName = Internal.SFN_GetFullSprocName(@TestSProcId)
         SET @Message = 'Test ' + @FullSprocName + ' failed. [' + @ExpectedErrorContextMessage + '] Expected error was not raised: ' + @ExpectedErrorInfo
         EXEC Assert.Fail @Message
      END
   END TRY
   BEGIN CATCH
      BEGIN TRY
         -- We will collect the info about an expected error (if any) at this point. There are scenarios where this info 
         -- is lost during CollectTestSProcErrorInfo. That is the case when we are forced to do a rollback in CollectTestSProcErrorInfo.
         EXEC Internal.GetExpectedErrorInfo @ExpectedErrorContextMessage OUT, @ExpectedErrorInfo OUT 

         EXEC @TestSprocErrorCode = Internal.CollectTestSProcErrorInfo
                                       @TestSessionId                 = @TestSessionId,
                                       @TestSProcId                   = @TestSProcId,
                                       @UseTSTRollback                = @UseTSTRollback,
                                       @UseTeardown                   = @UseTeardown,
                                       @StartTranCount                = @StartTranCount,
                                       @LastTestLogEntryIdBeforeTest  = @LastTestLogEntryIdBeforeTest
      END TRY
      BEGIN CATCH
         -- Some scenarios may cause CollectTestSProcErrorInfo to rollback transactions. 
         -- When that happens the @@TRANCOUNT mismatch will trigger an error with error number 266. We'll ignore that error here.
         IF (ERROR_NUMBER() != 266) EXEC Internal.Rethrow
      END CATCH
      
      IF (@TestSprocErrorCode = 0) 
      BEGIN
         SET @FullSprocName = Internal.SFN_GetFullSprocName(@TestSProcId)
         SET @Message = 'Test ' + @FullSprocName + ' passed. [' + @ExpectedErrorContextMessage + '] Expected error was raised: ' + @ExpectedErrorInfo
         EXEC Assert.Pass @Message

         GOTO LblBeforeTeardown
      END
      IF (@TestSprocErrorCode = 1) GOTO LblBeforeTeardown
      IF (@TestSprocErrorCode = 2) GOTO LblPostTest

   END CATCH

LblBeforeTeardown:
   --================================
   -- TEARDOWN
   --================================
   IF (@TeardownSProcId IS NOT NULL)
   BEGIN TRY
      UPDATE #Tmp_CrtSessionInfo SET Stage = 'X'
      EXEC Internal.RunOneSProc @TeardownSProcId
   END TRY
   BEGIN CATCH
      BEGIN TRY
         EXEC @TeardownSprocErrorCode = Internal.CollectTeardownSProcErrorInfo
                                                @TestSessionId                 = @TestSessionId,
                                                @TeardownSProcId               = @TeardownSProcId,
                                                @UseTSTRollback                = @UseTSTRollback,
                                                @StartTranCount                = @StartTranCount,
                                                @LastTestLogEntryIdBeforeTest  = @LastTestLogEntryIdBeforeTest
      END TRY
      BEGIN CATCH
         -- Some scenarios may cause CollectTeardownSProcErrorInfo to rollback transactions. 
         -- When that happens the @@TRANCOUNT mismatch will trigger an error with error number 266. We'll ignore that error here.
         IF (ERROR_NUMBER() != 266) EXEC Internal.Rethrow
      END CATCH
     
   END CATCH

LblPostTest:

   IF (@@TRANCOUNT > 0)
   BEGIN
      BEGIN TRY
         -- Rollback and in the same time preserves the log entries
         EXEC Internal.RollbackWithLogPreservation @TestSessionId, @LastTestLogEntryIdBeforeTest
      END TRY
      BEGIN CATCH
         -- RollbackWithLogPreservation will execute a ROLLBACK transaction so an error 266 caused by @@Trancount mismatch is expected. 
         IF (ERROR_NUMBER() != 266) EXEC Internal.Rethrow
      END CATCH
   END

END
GO
