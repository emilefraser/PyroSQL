SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- FUNCTION SFN_GetSuiteTypeId
-- Returns an ID that can be used to order suites based on their type:
--    0: Session Setup suite.
--    1: The anonymous suite.
--    2: A regular suite.
--    3: Session Setup teardown.
-- =======================================================================
CREATE FUNCTION Internal.SFN_GetSuiteTypeId(@SuiteName sysname) RETURNS int
AS
BEGIN

   IF (@SuiteName = '#SessionSetup#') RETURN 0
   IF (@SuiteName = '#SessionTeardown#') RETURN 3
   ELSE IF (@SuiteName IS NULL ) RETURN 1

   RETURN 2

END

GO
