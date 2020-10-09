SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE: PrintSystemErrorsForSession
-- It will print all the system errors that occured in the test session 
-- given by @TestSessionId
-- =======================================================================
CREATE PROCEDURE Internal.PrintSystemErrorsForSession
   @TestSessionId    int,           -- Identifies the test session.
   @ResultsFormat    varchar(10)    -- Indicates if the format in which the results will be printed.
                                    -- See the coments at the begining of the file under section 'Results Format'
AS
BEGIN
   
   DECLARE @SystemError       nvarchar(1000)

   DECLARE CrsSystemErrors CURSOR LOCAL FOR
   SELECT LogMessage FROM Data.SystemErrorLog WHERE TestSessionId = @TestSessionId ORDER BY CreatedTime

   IF (@ResultsFormat = 'XML')
   BEGIN
      PRINT REPLICATE(' ', 2) + '<SystemErrors>'
   END
      
   OPEN CrsSystemErrors
   FETCH NEXT FROM CrsSystemErrors INTO @SystemError
   WHILE @@FETCH_STATUS = 0
   BEGIN

      IF (@ResultsFormat = 'Text')
      BEGIN
         PRINT REPLICATE(' ', 4) + 'Error: ' + @SystemError
      END
      ELSE IF (@ResultsFormat = 'XML')
      BEGIN
         PRINT REPLICATE(' ', 4) + '<SystemError>' + Internal.SFN_EscapeForXml(@SystemError) + '</SystemError>'
      END
      
      FETCH NEXT FROM CrsSystemErrors INTO @SystemError
   END

   CLOSE CrsSystemErrors
   DEALLOCATE CrsSystemErrors

   IF (@ResultsFormat = 'XML')
   BEGIN
      PRINT REPLICATE(' ', 2) + '</SystemErrors>'
   END

END

GO
