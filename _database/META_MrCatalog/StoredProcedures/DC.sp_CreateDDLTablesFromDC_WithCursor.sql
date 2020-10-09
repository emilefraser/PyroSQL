SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [DC].[sp_CreateDDLTablesFromDC_WithCursor]
	@TargetDatabaseID INT --KD: Added this because Target DB ID will be the same across all entities created
AS

DECLARE @HubID INT
  
DECLARE hub_cursor1 CURSOR FOR
SELECT DISTINCT DataEntityID
FROM DC.vw_rpt_DatabaseFieldDetail
WHERE DatabaseID = 3;  
  
OPEN hub_cursor1  
  
FETCH NEXT FROM hub_cursor1   
INTO @HubID 
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
    
	EXECUTE dbo.sp_TestingDDL @HubID
  
  
    FETCH NEXT FROM hub_cursor1   
    INTO @HubID 
END   

CLOSE hub_cursor1;  
DEALLOCATE hub_cursor1;

select * from EXECUTION.DDLExecutionQueue 
order by CreatedDT desc

GO
