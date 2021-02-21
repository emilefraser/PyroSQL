SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[PrintDebug]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tool].[PrintDebug] AS' 
END
GO

ALTER PROCEDURE [tool].[PrintDebug]
(
    @variableName  NVARCHAR(MAX) = '',
    @variableValue NVARCHAR(MAX) = '',
    @printMessage  NVARCHAR(MAX) = ''
)
/*
EXECUTE dbo.usp_PrintDebug @variableName = 'maxDate', @variableValue = ''
EXECUTE dbo.usp_PrintDebug @printMessage = 'start_debug'
EXECUTE dbo.usp_PrintDebug @printMessage = 'end_debug'
EXECUTE dbo.usp_PrintDebug @printMessage = 'Test debug'
*/
AS
BEGIN
    DECLARE @Crlf NVARCHAR(10) = CHAR(13) ;
    BEGIN TRY
        IF @printMessage = ''
        IF @variableValue IS NOT NULL AND CAST(@variableValue AS NVARCHAR) != ''
        PRINT '@' + @variableName + ' = {' + CAST(@variableValue AS NVARCHAR) + '}'
        ELSE
        IF CAST(@variableValue AS NVARCHAR) = ''
        PRINT @variableName + ' = {Empty String}'
        ELSE
        IF @variableValue IS NULL
        PRINT @variableName + ' = {NULL}';

        IF @printMessage LIKE 'start_debug %'
        PRINT '/******* Start Debug' + REPLACE(@printMessage, 'start_debug' , ' ')  + @Crlf;

        IF @printMessage LIKE 'end_debug %'
        PRINT @Crlf + '--End Deubg ' + REPLACE(@printMessage, 'end_debug' , '') + ' *********/';

        IF @printMessage NOT LIKE '%_debug%'
        PRINT @printMessage;
    END TRY

    BEGIN CATCH
        EXECUTE tool.LogError;
    END CATCH
END;
GO
