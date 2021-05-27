SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[test spDouble Calculation]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[test spDouble Calculation] AS' 
END
GO
ALTER   PROCEDURE [dbo].[test spDouble Calculation]
AS
    BEGIN
-- assemble
        DECLARE
            @param INT
        ,   @expected INT
        ,   @actual INT;
        SET @param = 5;
        SET @expected = 10;
-- Act
        EXEC @actual = spDouble @param;
-- assert
        EXEC tSQLt.AssertEquals @Expected = @expected, @Actual = @actual,
            @Message = N'The calculation is incorrect.'; -- nvarchar(max)
    END;
GO
