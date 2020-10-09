SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE Procedure [DC].[sp_CreatePKFKLinkTableInDC_WithCursor]
AS

DECLARE @HubID INT
  
DECLARE hub_cursor3 CURSOR FOR
SELECT HubID
FROM DataManager.DMOD.Hub
ORDER BY HubID;  
  
OPEN hub_cursor3  
  
FETCH NEXT FROM hub_cursor3   
INTO @HubID 
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
    
	EXECUTE [DC].[sp_CreatePKFKLinkTableInDC] @HubID, 12
  
  
    FETCH NEXT FROM hub_cursor3   
    INTO @HubID 
END   

CLOSE hub_cursor3;  
DEALLOCATE hub_cursor3;

GO
