SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      RJ Oosthuizen
-- Create Date: 30/05/2019
-- Description: Manage business key fields
-- =============================================
CREATE PROCEDURE [APP].[sp_CRUD_BK_Field_Internal]
(
	@HubBusinessKeyID int, -- header id of hub businesskey table
	@NewSourceFieldID int, --selected field id(for new and update)
	@CurrentSourceFieldID int,--for update and delete
	@IsBaseEntityField bit,
    @TransactionAction nvarchar(20) = null, -- type of transaction, "Create", "Delete"
	  @TransactionPerson varchar(80), -- who actioned
   @MasterEntity varchar(50) -- from where actioned
)
AS
BEGIN
	DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction
	
	--create record
	
	IF @TransactionAction = 'Create'
		BEGIN
			DECLARE @HubBusinessKeyIDCompare INT --hubbkid to compare to provided hubbkid
			DECLARE @NewSourceFieldIDCompare INT --fieldid to compare to provided fieldid
			DECLARE @IsFound INT = 0 --if 0 then will do an insert(so create entry), if 1 then will only update(set isactive = 1 for that combination)
			
			DECLARE BKField_cursor CURSOR FOR   --declare cursor
				SELECT HubBusinessKeyID, FieldID
				FROM [DMOD].[HubBusinessKeyField] AS hbkf --get data from this table to compare to provided vars
		  
				OPEN BKField_cursor  
		  
				FETCH NEXT FROM BKField_cursor   --initial fetch(DO-While statement)
				INTO @HubBusinessKeyIDCompare, @NewSourceFieldIDCompare
		  
		    
			WHILE @@FETCH_STATUS = 0  
				BEGIN  
					
					IF(@HubBusinessKeyID = @HubBusinessKeyIDCompare AND @NewSourceFieldID = @NewSourceFieldIDCompare) --if comparison is met
						BEGIN
							SET @IsFound = 1 --now wont update
							UPDATE [DMOD].[HubBusinessKeyField]
							SET IsActive = 1,
							UpdatedDT = @TransactionDT,
							IsBaseEntityField = @IsBaseEntityField
							WHERE HubBusinessKeyID = @HubBusinessKeyID
							AND FieldID = @NewSourceFieldID
							BREAK; -- break from loop once condition is met
						END

					FETCH NEXT FROM BKField_cursor   
					INTO @HubBusinessKeyIDCompare, @NewSourceFieldIDCompare --while fetch
		
				END   
		
			CLOSE BKField_cursor;  
			DEALLOCATE BKField_cursor;  

			If(@IsFound = 0) --nothing has been found so insert will commence
				BEGIN
					--Insert new record into hub bk
					INSERT INTO [DMOD].[HubBusinessKeyField] (HubBusinessKeyID, FieldID, IsBaseEntityField, CreatedDT, IsActive)
					VALUES (@HubBusinessKeyID, @NewSourceFieldID, @IsBaseEntityField, @TransactionDT, 1)
				END

		END
	--update record
	
	IF @TransactionAction = 'Update'
	
		BEGIN
			--set record status inactive = 0 (soft delete record)
			Update [DMOD].[HubBusinessKeyField] 
			SET FieldID = @NewSourceFieldID,
			IsBaseEntityField = @IsBaseEntityField,
			UpdatedDT = @TransactionDT
			WHERE HubBusinessKeyID = @HubBusinessKeyID
			AND FieldID = @CurrentSourceFieldID
		END

	--delete record
	
	IF @TransactionAction = 'Delete'
	
		BEGIN
			--set record status inactive = 0 (soft delete record)
			Update [DMOD].[HubBusinessKeyField] 
			SET IsActive = 0, 
			UpdatedDT = @TransactionDT
			WHERE HubBusinessKeyID = @HubBusinessKeyID
			AND FieldID = @CurrentSourceFieldID
		END
	--reactivate link	
	IF @TransactionAction = 'UnDelete'
	
		BEGIN
			--set record status inactive = 1
			Update [DMOD].[HubBusinessKeyField] 
			SET IsActive = 1, 
			UpdatedDT = @TransactionDT
			WHERE HubBusinessKeyID = @HubBusinessKeyID
			AND FieldID = @CurrentSourceFieldID
		END

END

GO
