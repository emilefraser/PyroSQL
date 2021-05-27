SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[PrintSystemErrorsForSession]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[PrintSystemErrorsForSession] AS' 
END
GO

-- =======================================================================
-- PROCEDURE: PrintSystemErrorsForSession
-- It will print all the system errors that occured in the test session 
-- given by @TestSessionId
-- =======================================================================
ALTER   PROCEDURE [internal].[PrintSystemErrorsForSession]
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
