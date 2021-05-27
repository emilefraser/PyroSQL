SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[ExpectNoException]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[ExpectNoException] AS' 
END
GO

ALTER PROCEDURE [tSQLt].[ExpectNoException]
  @Message NVARCHAR(MAX) = NULL
AS
BEGIN
 IF(EXISTS(SELECT 1 FROM #ExpectException WHERE ExpectException = 0))
 BEGIN
   DELETE #ExpectException;
   RAISERROR('Each test can only contain one call to tSQLt.ExpectNoException.',16,10);
 END;
 IF(EXISTS(SELECT 1 FROM #ExpectException WHERE ExpectException = 1))
 BEGIN
   DELETE #ExpectException;
   RAISERROR('tSQLt.ExpectNoException cannot follow tSQLt.ExpectException inside a single test.',16,10);
 END;
 
 INSERT INTO #ExpectException(ExpectException, FailMessage)
 VALUES(0, @Message);
END;


GO
