SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE Procedure [DC].[sp_CreateSatTableInDC_WithCursor]
AS

DECLARE @HubID INT
  
DECLARE hub_cursor2 CURSOR FOR
SELECT HubID
FROM DataManager.DMOD.Hub
ORDER BY HubID;  
  
OPEN hub_cursor2  
  
FETCH NEXT FROM hub_cursor2   
INTO @HubID 
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
    
	EXECUTE [DC].[sp_CreateSatelliteTableInDC] @HubID, 12
  
  
    FETCH NEXT FROM hub_cursor2   
    INTO @HubID 
END   

CLOSE hub_cursor2;  
DEALLOCATE hub_cursor2;

GO
