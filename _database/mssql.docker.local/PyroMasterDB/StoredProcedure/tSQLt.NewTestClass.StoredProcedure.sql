SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[NewTestClass]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[NewTestClass] AS' 
END
GO

ALTER PROCEDURE [tSQLt].[NewTestClass]
    @ClassName NVARCHAR(MAX)
AS
BEGIN
  BEGIN TRY
    EXEC tSQLt.Private_DisallowOverwritingNonTestSchema @ClassName;

    EXEC tSQLt.DropClass @ClassName = @ClassName;

    DECLARE @QuotedClassName NVARCHAR(MAX);
    SELECT @QuotedClassName = tSQLt.Private_QuoteClassNameForNewTestClass(@ClassName);

    EXEC ('CREATE SCHEMA ' + @QuotedClassName);  
    EXEC tSQLt.Private_MarkSchemaAsTestClass @QuotedClassName;
  END TRY
  BEGIN CATCH
    DECLARE @ErrMsg NVARCHAR(MAX);SET @ErrMsg = ERROR_MESSAGE() + ' (Error originated in ' + ERROR_PROCEDURE() + ')';
    DECLARE @ErrSvr INT;SET @ErrSvr = ERROR_SEVERITY();
    
    RAISERROR(@ErrMsg, @ErrSvr, 10);
  END CATCH;
END;


GO
