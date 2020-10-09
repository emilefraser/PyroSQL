SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      RJ Oosthuizen
-- Create Date: 30/05/2019
-- Description: Manage hub and business key links
-- =============================================
CREATE PROCEDURE [APP].[sp_CRUD_Hierarchical_Link_Internal]
(
   @HierarchicalLinkID int, --primary key
   @HubID int, --Hub primary key
   @LinkName varchar(max), -- h link name
   @PKFieldID int, --PK FieldID
   @ParentFieldID int, --FK FieldID
   @TransactionAction nvarchar(20) = null, -- type of transaction, "Create", "Delete"
      @TransactionPerson varchar(80), -- who actioned
   @MasterEntity varchar(50) -- from where actioned

)
AS
BEGIN

	DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction
	--hub name
	--DECLARE @HLinkName varchar(200) = (SELECT TOP 1 HubName 
	--									FROM DMOD.Hub 
	--									WHERE HubID = @HubID)
	
	----remove hub from name
	--SET @HLinkName = SUBSTRING(@HLinkName, 5, LEN(@HLinkName))

	----combine for Hlink name
	--DECLARE @LinkName varchar(300) = 'HLINK_' + @HLinkName + '_' + @HLinkName
	--create record
	
	IF @TransactionAction = 'Create'
		BEGIN
			DECLARE @HubIDCompare INT --hubid to compare to provided hubid
			DECLARE @PKFieldIDCompare INT --pkfieldid to compare to provided pkfieldid
			DECLARE @ParentFieldIDCompare INT --parentfieldid to compare to provided parentfieldid
			DECLARE @IsFound INT = 0 --if 0 then will do an insert(so create entry), if 1 then will only update(set isactive = 1 for that combination)
			
			DECLARE PKFKHLink_cursor CURSOR FOR --declare cursor
				SELECT HubID, PKFieldID, ParentFieldID
				FROM [DMOD].[HierarchicalLink] AS hl --get data from this table to compare to provided vars
		  
				OPEN PKFKHLink_cursor  
		  
				FETCH NEXT FROM PKFKHLink_cursor --initial fetch(DO-While statement)
				INTO @HubIDCompare, @PKFieldIDCompare, @ParentFieldIDCompare
		  
		    
			WHILE @@FETCH_STATUS = 0  
				BEGIN  
				
					IF(@HubID = @HubIDCompare AND @PKFieldID = @PKFieldIDCompare AND @ParentFieldID = @ParentFieldIDCompare) --if comparison is met
						BEGIN
							SET @IsFound = 1 --now wont update
							UPDATE [DMOD].[HierarchicalLink]
							SET IsActive = 1,
							UpdatedDT = @TransactionDT
							WHERE HubID = @HubID
							AND PKFieldID = @PKFieldID
							AND ParentFieldID = @ParentFieldID
							BREAK; -- break from loop once condition is met
						END

					FETCH NEXT FROM PKFKHLink_cursor   
					INTO @HubIDCompare, @PKFieldIDCompare, @ParentFieldIDCompare --while fetch
		
				END   
		
			CLOSE PKFKHLink_cursor;  
			DEALLOCATE PKFKHLink_cursor;  

			If(@IsFound = 0) --nothing has been found so insert will commence
				BEGIN
					--Insert new record into hub bk
					INSERT INTO [DMOD].[HierarchicalLink] (HubID, HierarchicalLinkName, PKFieldID, ParentFieldID, CreatedDT, IsActive)
					VALUES (@HubID, @LinkName, @PKFieldID, @ParentFieldID, @TransactionDT, 1)
				END
	END
	--Update record
	IF @TransactionAction = 'Update'
	
	
		BEGIN
			--Insert new record into hub bk
			UPDATE [DMOD].[HierarchicalLink]
			SET HierarchicalLinkName = @LinkName, 
			PKFieldID = @PKFieldID, 
			ParentFieldID = @ParentFieldID, 
			UpdatedDT = @TransactionDT
			WHERE HierarchicalLinkID = @HierarchicalLinkID
		END
	
	--delete record
	
	IF @TransactionAction = 'Delete'
	
		BEGIN
			--set record status inactive = 0 (soft delete record)
			Update [DMOD].[HierarchicalLink] 
			SET IsActive = 0, 
			UpdatedDT = @TransactionDT
			WHERE HierarchicalLinkID = @HierarchicalLinkID
		END

END


GO
