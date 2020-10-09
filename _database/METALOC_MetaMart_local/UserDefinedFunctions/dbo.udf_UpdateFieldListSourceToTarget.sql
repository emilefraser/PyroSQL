SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

 
CREATE FUNCTION [dbo].[udf_UpdateFieldListSourceToTarget]
(
    @InString VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @CurrentPos INT = 1
    DECLARE @FinalString VARCHAR(MAX) = 'target.' + SUBSTRING(@InString, @CurrentPos, CHARINDEX('],[', @InString, @CurrentPos)) + ' = source.' + SUBSTRING(@InString, @CurrentPos, CHARINDEX('],[', @InString, @CurrentPos))
    DECLARE @FieldLength INT
    --SELECT @FinalString
 
    SET @CurrentPos = CHARINDEX('],[', @InString, @CurrentPos) + 1
    --SELECT @CurrentPos AS '@CurrentPos'
 
    WHILE CHARINDEX('],[', @InString, @CurrentPos) > 0
    BEGIN
        SET @FieldLength = CHARINDEX('],[', @InString, @CurrentPos + 1) - @CurrentPos
        --SELECT @FieldLength AS [Length]
        SET @FinalString = @FinalString + ', [target].' + SUBSTRING(@InString, @CurrentPos + 1, @FieldLength) + ' = [source].' + SUBSTRING(@InString, @CurrentPos + 1, @FieldLength)
        SET @CurrentPos = CHARINDEX('],[', @InString, @CurrentPos) + 1
        --SELECT @CurrentPos AS '@CurrentPos'
        --SELECT @FinalString AS '@FinalString'
 
    END
 
    SET @FieldLength = LEN(@InString) - @CurrentPos
    --SELECT @FieldLength AS [Length]
    SET @FinalString = @FinalString + ', [target].' + SUBSTRING(@InString, @CurrentPos + 1, @FieldLength) + ' = [source].' + SUBSTRING(@InString, @CurrentPos + 1, @FieldLength)
    --SELECT @FinalString
    
    RETURN @FinalString
 
END

GO
