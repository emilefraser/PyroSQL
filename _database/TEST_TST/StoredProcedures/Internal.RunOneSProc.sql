SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE RunOneSProc
-- This will run the given TST test procedure. Caled by RunOneTestInternal
-- =======================================================================
CREATE PROCEDURE Internal.RunOneSProc
   @TestId           int               -- Identifies the test.
AS
BEGIN
   DECLARE @SqlCommand     nvarchar(1000)
   
   SET @SqlCommand = Internal.SFN_GetFullSprocName(@TestId)
   EXEC @SqlCommand

END

GO
