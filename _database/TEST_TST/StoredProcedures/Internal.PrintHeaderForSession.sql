SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: PrintHeaderForSession
-- It will print the first lines in the result screen orin the XML file
-- =======================================================================
CREATE PROCEDURE Internal.PrintHeaderForSession
   @TestSessionId    int,         -- Identifies the test session.
   @ResultsFormat    varchar(10), -- Indicates if the format in which the results will be printed.
                                  -- See the coments at the begining of the file under section 'Results Format'
   @NoTimestamp      bit = 0      -- Indicates that no timestamp or duration info should be printed in results output
AS
BEGIN

   DECLARE @TestSessionStart           datetime
   DECLARE @TestSessionFinish          datetime
   DECLARE @TestSessionStatus          bit
   DECLARE @TestSessionStatusString    varchar(16)
   DECLARE @ResultMessage              nvarchar(1000)

   SELECT 
      @TestSessionStart   = TestSessionStart, 
      @TestSessionFinish  = TestSessionFinish
   FROM Data.TestSession
   WHERE TestSessionId = @TestSessionId
   
   SET @TestSessionStatus = Internal.SFN_GetSessionStatus(@TestSessionId) 

   IF (@TestSessionStatus = 1) SET @TestSessionStatusString = 'Passed'
   SET @TestSessionStatusString = 'Failed'

   IF (@ResultsFormat = 'XML')
   BEGIN
      IF (@NoTimestamp=0)
      BEGIN
         SET @ResultMessage = '<TST' + 
            ' status="' + @TestSessionStatusString + '"' + 
            ' testSessionId="' + CAST(@TestSessionId AS varchar) + '"' + 
            ' start="' + CONVERT(nvarchar(20), @TestSessionStart, 108) + '"' + 
            ' finish="' + CONVERT(nvarchar(20), @TestSessionFinish, 108) + '"' + 
            ' duration="' + CONVERT(nvarchar(10), DATEDIFF(ms, @TestSessionStart, @TestSessionFinish)) + '"' + 
            ' >'
      END
      ELSE
      BEGIN
         SET @ResultMessage = '<TST' + 
            ' status="' + @TestSessionStatusString + '"' + 
            ' >'
     END
     PRINT @ResultMessage 
   END

END

GO
