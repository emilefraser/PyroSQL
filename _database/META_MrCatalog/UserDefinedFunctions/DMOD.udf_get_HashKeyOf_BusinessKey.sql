SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
    ? Who ? Emile Fraser
    ? Why ? Returns Hashkey of a standard business key
    ? When ? 2020-03-20
    ? How ? 
       Convert the Business Key(Keys) to a Hashable value via SHA1
*/
/*
    SELECT [DMOD].[udf_get_HashKeyOf_BusinessKey]('176546,55555,Blah Blah')
    SELECT [DMOD].[udf_get_HashKeyOf_BusinessKey]('NULL')
    SELECT [DMOD].[udf_get_HashKeyOf_BusinessKey](NULL)
    SELECT [DMOD].[udf_get_HashKeyOf_BusinessKey]('176546')
*/

CREATE   FUNCTION [DMOD].[udf_get_HashKeyOf_BusinessKey](@BusinessKeyList NVARCHAR(MAX))
RETURNS VARCHAR(40)
AS
BEGIN

    DECLARE @BusinessKeyConcat NVARCHAR(MAX) = ''
    DECLARE @ReturnHash VARCHAR(40)

    -- Pipe Delimeter chosen as the delimeter of choice
    -- The delimeter is not sent as param, as we are using CONCAT to keep all null values in
    -- as CONCAT_WS would eliminate them
    DECLARE @delimeter NVARCHAR(1) = '|'
    DECLARE @delimeter_spaces NVARCHAR(3) = ' | '

   IF(@BusinessKeyList IS NULL)
   BEGIN
        SET @ReturnHash = DataManager.DMOD.udf_get_GhostRecord_HashKey()
   END
   ELSE
   BEGIN

    SELECT  
	    @BusinessKeyConcat += CONCAT_WS(
                            @delimeter_spaces
                            , COALESCE(
                                    UPPER(
                                        LTRIM(
                                            RTRIM(
                                                flat.i.value ('(./text())[1]', 'nvarchar(4000)')
                                            )
                                        )
                                    ), 'NA'
                                ), ''
                        )
    FROM (
        SELECT 
		      outside = CONVERT(XML, '<i>' + REPLACE(@BusinessKeyList, @delimeter, '</i><i>') + '</i>').query ('.') 
    ) AS sq
    CROSS APPLY
	    outside.nodes ('i') AS flat(i)

    -- Remove Trailing delimeter and space
    SET @BusinessKeyConcat =  SUBSTRING(@BusinessKeyConcat, 1, LEN(@BusinessKeyConcat) - LEN(@delimeter_spaces))

    -- Returns the final hashed value
    SET @ReturnHash =  CONVERT(VARCHAR(40),					         HASHBYTES ('SHA1',						         CONVERT (VARCHAR(MAX), @BusinessKeyConcat
                                 )
                              )
                   ,2)
    END

    RETURN @ReturnHash
END

GO
