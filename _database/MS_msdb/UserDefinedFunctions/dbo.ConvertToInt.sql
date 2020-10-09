SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE FUNCTION dbo.ConvertToInt(@string nvarchar(255), @maxValue int, @defValue int) RETURNS int
AS
BEGIN
    DECLARE @value bigint   
    SET @value = @defValue 
    SET @string = LTRIM(RTRIM(@string))

    -- Check if there is any character other than 0-9 in the string.
    IF ((@string IS NOT NULL AND @string <> N'') AND (@string NOT LIKE '%[^0-9]%'))
    BEGIN
        --INT's have a max of 10 digits
        IF(LEN(@string) <= 10)
        BEGIN
        -- Try converting to bigint. Return default if the value is bigger than @maxValue
        SET @value = CONVERT(bigint, @string)
        IF(@value > CONVERT(bigint, @maxValue))
            SET @value = @defValue
        END
    END

    RETURN CONVERT(int, @value)
END

GO
