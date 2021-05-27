SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[ExpectException]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[ExpectException] AS' 
END
GO

ALTER PROCEDURE [tSQLt].[ExpectException]
@ExpectedMessage NVARCHAR(MAX) = NULL,
@ExpectedSeverity INT = NULL,
@ExpectedState INT = NULL,
@Message NVARCHAR(MAX) = NULL,
@ExpectedMessagePattern NVARCHAR(MAX) = NULL,
@ExpectedErrorNumber INT = NULL
AS
BEGIN
 IF(EXISTS(SELECT 1 FROM #ExpectException WHERE ExpectException = 1))
 BEGIN
   DELETE #ExpectException;
   RAISERROR('Each test can only contain one call to tSQLt.ExpectException.',16,10);
 END;
 
 INSERT INTO #ExpectException(ExpectException, ExpectedMessage, ExpectedSeverity, ExpectedState, ExpectedMessagePattern, ExpectedErrorNumber, FailMessage)
 VALUES(1, @ExpectedMessage, @ExpectedSeverity, @ExpectedState, @ExpectedMessagePattern, @ExpectedErrorNumber, @Message);
END;


GO
