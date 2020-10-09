SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [DC].[sp_CreateHubTableInDC_WithCursor]
	@TargetDatabaseID INT --KD: Added this because Target DB ID will be the same across all entities created
AS

DECLARE @HubID INT
  
DECLARE hub_cursor1 CURSOR FOR
SELECT HubID
FROM DataManager.DMOD.Hub
WHERE IsActive = 1
ORDER BY HubID;  
  
OPEN hub_cursor1  
  
FETCH NEXT FROM hub_cursor1   
INTO @HubID 
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
    
	EXECUTE [DC].[sp_CreateHubTableInDC] @HubID, @TargetDatabaseID
  
  
    FETCH NEXT FROM hub_cursor1   
    INTO @HubID 
END   

CLOSE hub_cursor1;  
DEALLOCATE hub_cursor1;

GO
