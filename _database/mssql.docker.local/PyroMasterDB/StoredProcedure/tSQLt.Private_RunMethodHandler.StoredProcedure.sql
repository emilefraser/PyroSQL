SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_RunMethodHandler]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Private_RunMethodHandler] AS' 
END
GO

ALTER PROCEDURE [tSQLt].[Private_RunMethodHandler]
  @RunMethod NVARCHAR(MAX),
  @TestResultFormatter NVARCHAR(MAX) = NULL,
  @TestName NVARCHAR(MAX) = NULL
AS
BEGIN
  SELECT @TestResultFormatter = ISNULL(@TestResultFormatter,tSQLt.GetTestResultFormatter());

  EXEC tSQLt.Private_Init;
  IF(@@ERROR = 0)
  BEGIN  
    IF(EXISTS(SELECT * FROM sys.parameters AS P WHERE P.object_id = OBJECT_ID(@RunMethod) AND name = '@TestName'))
    BEGIN
      EXEC @RunMethod @TestName = @TestName, @TestResultFormatter = @TestResultFormatter;
    END;
    ELSE
    BEGIN  
      EXEC @RunMethod @TestResultFormatter = @TestResultFormatter;
    END;
  END;
END;
GO
