SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
=============================================
Author: Emile Fraser
Create Date: 16 June 2019
Description: Returns a field list from the Data Catalog for an Select St
=============================================

--!~ LoadConfigID
, @LoadConfigID int = 2
-- End of LoadConfigID ~!

SELECT [DMOD].[udf_get_LoadConfigID](12288)

*/
CREATE FUNCTION [DMOD].[udf_get_LoadConfigID]
(
    @LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @LoadConfigReturn VARCHAR(MAX) = ''

	SELECT 
	   @LoadConfigReturn = @LoadConfigReturn + CHAR(9) + CHAR(9) + CHAR(9) + ', @LoadConfigID int = ' + CONVERT(VARCHAR(MAX), lc.LoadConfigID) + CHAR(10)
	FROM 
	   [DMOD].[LoadConfig] AS lc
	WHERE 
	   LoadConfigID = @LoadConfigID

	SET	@LoadConfigReturn =	'--!~ LoadConfigID'
							+ CHAR(10)
							+ @LoadConfigReturn
							+ '-- End of LoadConfigID ~!'

    RETURN @LoadConfigReturn

END



GO
