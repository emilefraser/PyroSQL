SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      RJ Oosthuizen
-- Create Date: 30/05/2019
-- Description: Manage hub and business key links
-- =============================================
CREATE PROCEDURE [APP].[sp_CRUD_Hub_BK_Internal]
(
   @HubBusinessKeyID int, --primary key
   @HubID int, --primary key of the selected hub
   @FieldSortOrder int, --order of the column of the field in the dataentity
   @BKFriendlyName varchar(200), --friendlyname for the selected field
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
			--Insert new record into hub bk
			INSERT INTO [DMOD].[HubBusinessKey] (HubID, FieldSortOrder, BKFriendlyName, CreatedDT, IsActive)
			VALUES (@HubID, @FieldSortOrder, @BKFriendlyName, @TransactionDT, 1)
		END
	
	--Update record
	IF @TransactionAction = 'Update'
	
	
		BEGIN
			--IUpdate record in table
			Update [DMOD].[HubBusinessKey] 
			SET BKFriendlyName = @BKFriendlyName,
			FieldSortOrder = @FieldSortOrder, 
			UpdatedDT = @TransactionDT
			WHERE HubBusinessKeyID = @HubBusinessKeyID
		END
	
	--delete record
	
	IF @TransactionAction = 'Delete'
	
		BEGIN
			--set record status inactive = 0 (soft delete record)
			Update [DMOD].[HubBusinessKey] 
			SET IsActive = 0, 
			UpdatedDT = @TransactionDT
			WHERE HubBusinessKeyID = @HubBusinessKeyID


			--set record status inactive = 0 (soft delete record), for all child records
			Update [DMOD].[HubBusinessKeyField] 
			SET IsActive = 0, 
			UpdatedDT = @TransactionDT
			WHERE HubBusinessKeyID = @HubBusinessKeyID
		END

END

GO
