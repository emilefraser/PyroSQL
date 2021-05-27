SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_Print]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Private_Print] AS' 
END
GO
ALTER PROCEDURE [tSQLt].[Private_Print] 
    @Message NVARCHAR(MAX),
    @Severity INT = 0
AS 
BEGIN
    DECLARE @SPos INT;SET @SPos = 1;
    DECLARE @EPos INT;
    DECLARE @Len INT; SET @Len = LEN(@Message);
    DECLARE @SubMsg NVARCHAR(MAX);
    DECLARE @Cmd NVARCHAR(MAX);
    
    DECLARE @CleanedMessage NVARCHAR(MAX);
    SET @CleanedMessage = REPLACE(@Message,'%','%%');
    
    WHILE (@SPos <= @Len)
    BEGIN
      SET @EPos = CHARINDEX(CHAR(13)+CHAR(10),@CleanedMessage+CHAR(13)+CHAR(10),@SPos);
      SET @SubMsg = SUBSTRING(@CleanedMessage, @SPos, @EPos - @SPos);
      SET @Cmd = N'RAISERROR(@Msg,@Severity,10) WITH NOWAIT;';
      EXEC sp_executesql @Cmd, 
                         N'@Msg NVARCHAR(MAX),@Severity INT',
                         @SubMsg,
                         @Severity;
      SELECT @SPos = @EPos + 2,
             @Severity = 0; --Print only first line with high severity
    END

    RETURN 0;
END;
GO
