SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE Procedure [DC].[sp_CreateStageTableDDLFromDC_WithCursor]
AS

DECLARE @DataEntityID INT
  
DECLARE ddl_cursor CURSOR FOR
SELECT DISTINCT DataEntityID
FROM DataManager.DC.vw_rpt_DatabaseFieldDetail
WHERE DatabaseID = 11
AND DataEntityID IS NOT NULL
ORDER BY DataEntityID;  
  
OPEN ddl_cursor  
  
FETCH NEXT FROM ddl_cursor   
INTO @DataEntityID 
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
    
	EXECUTE [dbo].[sp_TestingDDL] @DataEntityID
  
  
    FETCH NEXT FROM ddl_cursor   
    INTO @DataEntityID 
END   

CLOSE ddl_cursor;  
DEALLOCATE ddl_cursor;

GO
