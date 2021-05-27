SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[EnsureSuite]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[EnsureSuite] AS' 
END
GO

-- =======================================================================
-- PROCEDURE EnsureSuite
-- This will make sure that the given suite is recorded in the table Suite
-- It will return the Suite Id in @SuiteId
-- =======================================================================
ALTER   PROCEDURE [internal].[EnsureSuite]
   @TestSessionId    int,              -- Identifies the test session.
   @SchemaName       sysname,          -- The schema name 
   @SuiteName        sysname,          -- The suite name
   @SuiteId          int OUTPUT        -- At return will indicate 
AS
BEGIN

   -- If this is the anonymous suite we'll ignore which schema is in. 
   IF @SuiteName IS NULL SET @SchemaName = NULL

   SET @SuiteId = NULL
   SELECT @SuiteId = SuiteId FROM Data.Suite 
   WHERE 
      @TestSessionId = TestSessionId 
      AND (SchemaName = @SchemaName OR (SchemaName IS NULL AND @SchemaName IS NULL) )
      AND (SuiteName = @SuiteName OR (SuiteName IS NULL AND @SuiteName IS NULL) )
   IF(@SuiteId IS NOT NULL) RETURN 0

   INSERT INTO Data.Suite(TestSessionId, SchemaName, SuiteName) VALUES(@TestSessionId, @SchemaName, @SuiteName)
   SET @SuiteId = SCOPE_IDENTITY()
   
   RETURN 0

END
GO
