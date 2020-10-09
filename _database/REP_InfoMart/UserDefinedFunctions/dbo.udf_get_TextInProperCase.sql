SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[udf_get_TextInProperCase](@String VARCHAR(250))
RETURNS VARCHAR(250)
AS
BEGIN
    DECLARE 
		@xml XML
	,	@delemiter VARCHAR(5)
	,	@Propercase VARCHAR(250)
    
	SET @delemiter = ' '

    -- Convert to XML with space as node
    SET @xml = CAST(('<String>' + REPLACE(@String, @delemiter, '</String><String>') + '</String>') AS XML)

    ;WITH cte
        AS (
			SELECT 
				a.value('.', 'varchar(max)') AS strings
            FROM 
				@Xml.nodes('String') AS FN(a)
		)

        SELECT @ProperCase = STUFF (
										(
											SELECT 
												' ' + UPPER(LEFT(strings, 1)) + LOWER(SUBSTRING(strings, 2, LEN(strings)))
											FROM 
												cte FOR xml PATH('')
										), 1, 1, ''
									)


    RETURN @ProperCase
END
GO
