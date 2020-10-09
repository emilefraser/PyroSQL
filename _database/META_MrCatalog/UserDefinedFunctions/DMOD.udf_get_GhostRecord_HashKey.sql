SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
    ? Who ? Emile Fraser
    ? Why ? Returns Acctech's Standard Ghost Record Hash
    ? When ? 20120-01-20
    ? How ? 
       Just All the Function

*/

CREATE FUNCTION [DMOD].[udf_get_GhostRecord_HashKey]()
RETURNS VARCHAR(40)
AS
BEGIN

    DECLARE @ReturnValue VARCHAR(40) = (
	        SELECT CONVERT(VARCHAR(40),					         HASHBYTES ('SHA1',						         CONVERT (VARCHAR(MAX),							         COALESCE(UPPER(LTRIM(RTRIM('NA'))),'')                                  )						                                     )            ,2)
     )

	RETURN @ReturnValue
END

GO
