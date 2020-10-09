SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE Procedure [DC].[sp_CreateStageTableInDC_WithCursor]
AS

DECLARE @HubID INT
  
DECLARE hub_cursor CURSOR FOR
SELECT HubID
FROM DataManager.DMOD.Hub
ORDER BY HubID;  
  
OPEN hub_cursor  
  
FETCH NEXT FROM hub_cursor   
INTO @HubID 
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
    
	EXECUTE [DC].[sp_CreateStageTableInDC] @HubID, 5
  
  
    FETCH NEXT FROM hub_cursor   
    INTO @HubID 
END   

CLOSE hub_cursor;  
DEALLOCATE hub_cursor;

GO
