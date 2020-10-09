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

SELECT [DMOD].[udf_get_LoadConfigID](55)

*/
CREATE FUNCTION [DMOD].[udf_get_HubName_HubID]
(
    @HubID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @HubName VARCHAR(MAX) = 
	(
		SELECT HubName FROM DMOD.Hub WHERE HubID = @HubID
	)
	RETURN @HubName

END



GO
