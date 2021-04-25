SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[RunOneSuiteInternal]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[RunOneSuiteInternal] AS' 
END
GO


-- =======================================================================
-- PROCEDURE RunOneSuiteInternal
-- Runs a given test suite. 
-- =======================================================================
ALTER   PROCEDURE [internal].[RunOneSuiteInternal]
   @TestSessionId    int,              -- Identifies the test session.
                                       -- Note: this is provided as a optimization. It could be determined based on @SuiteId
   @SuiteId          int               -- Identifies the suite.
AS
BEGIN

   DECLARE @TestSProcId             int
   DECLARE @SetupSProcId            int
   DECLARE @TeardownSProcId         int
   DECLARE @ErrorMessage            nvarchar(4000)
   
   SELECT @SetupSProcId    = TestId FROM Data.Test WHERE SuiteId = @SuiteId AND SProcType = 'Setup'
   SELECT @TeardownSProcId = TestId FROM Data.Test WHERE SuiteId = @SuiteId AND SProcType = 'Teardown'

   DECLARE CrsTests CURSOR LOCAL FOR
   SELECT TestId 
   FROM Data.Test 
   WHERE SuiteId = @SuiteId AND SProcType = 'Test'
   ORDER By TestId

   OPEN CrsTests
   FETCH NEXT FROM CrsTests INTO @TestSProcId
   WHILE @@FETCH_STATUS = 0
   BEGIN
   
      BEGIN TRY

         EXEC Internal.RunOneTestInternal
               @TestSessionId    ,
               @TestSProcId      ,
               @SetupSProcId     ,
               @TeardownSProcId  

         IF ( (SELECT COUNT(1) FROM Data.TestLog WHERE TestSessionId = @TestSessionId AND TestId = @TestSProcId AND EntryType IN('P', 'I', 'F', 'E')) = 0 )
         BEGIN
            -- We don't want here to call Assert.Fail because that raises an error. We'll simply insert the error message in TestLog
            INSERT INTO Data.TestLog(TestSessionId, TestId, EntryType, LogMessage) 
            VALUES (@TestSessionId, @TestSProcId, 'F', 'No Assert, Fail, Pass or Ignore was invoked by this test. You must call at least one TST API that performs a validation, records a failure, records a pass or ignores the test (Assert..., Pass, Ignore, Fail, etc.)')
         END

      END TRY
      BEGIN CATCH
         -- RunOneTestInternal should trap all possible errors and handle them
         -- We should not get into this situation. 
         
         -- TODO: can we extract the below string building in a function? 
         SET @ErrorMessage =  'TST Internal Error in RunOneSuiteInternal. Unexpected error: ' +
                              CAST(ERROR_NUMBER() AS varchar) + ', ' + ERROR_MESSAGE() + 
                              ' Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A') + '. Line: ' + CAST(ERROR_LINE() AS varchar)
         EXEC Internal.LogErrorMessage @ErrorMessage

      END CATCH

      -- Update #Tmp_CrtSessionInfo to indicate we are outside of any test stored procedure.
      UPDATE #Tmp_CrtSessionInfo SET TestId = -1, Stage = '-'

      FETCH NEXT FROM CrsTests INTO @TestSProcId
   END

   CLOSE CrsTests
   DEALLOCATE CrsTests

END
GO
