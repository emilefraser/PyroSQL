SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      RJ Oosthuizen
-- Create Date: 30/05/2019
-- Description: Manage hub and business key links
-- =============================================
CREATE PROCEDURE [APP].[sp_CRUD_PKFK_Link_Name_Internal]
(
   @PKFKLinkID int, --primary key
   @ParentHubNameVariation varchar(150),
   @ParentHubID int, --PK Hub ID
   @ChildHubID int, --FK Hub ID
   @LinkName varchar(200), --name of link
   @TransactionAction nvarchar(20) = null, -- type of transaction, "Create", "Delete"
   @TransactionPerson varchar(80), -- who actioned
   @MasterEntity varchar(50) -- from where actioned

)
AS
BEGIN

	DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction
	SET @ParentHubNameVariation = NULLIF(@ParentHubNameVariation, '')
	----get pk and fk hub name
	--DECLARE @PKHubName varchar(200) = (SELECT TOP 1 HubName 
	--									FROM DMOD.Hub 
	--									WHERE HubID = @ParentHubID)
	--DECLARE @FKHubName varchar(200) = (SELECT TOP 1 HubName 
	--									FROM DMOD.Hub 
	--									WHERE HubID = @ChildHubID)
	----remove hub from name
	--SET @PKHubName = SUBSTRING(@PKHubName, 5, LEN(@PKHubName))
	--SET @FKHubName = SUBSTRING(@FKHubName, 5, LEN(@FKHubName))

	----combine for link name
	--DECLARE @LinkName varchar(300) = 'LINK_' + @PKHubName + '_' + @FKHubName
	
	--create record
	
	IF @TransactionAction = 'Create'
		
	
		BEGIN
			--Insert new record into hub bk
			INSERT INTO [DMOD].[PKFKLink] (LinkName, ParentHubNameVariation, ParentHubID, ChildHubID, CreatedDT, IsActive)
			VALUES (@LinkName, @ParentHubNameVariation, @ParentHubID, @ChildHubID, @TransactionDT, 1)
		END
	
	--Update record
	IF @TransactionAction = 'Update'
	
	
		BEGIN
			--Insert new record into hub bk
			UPDATE [DMOD].[PKFKLink]
			SET LinkName = @LinkName,
			ParentHubNameVariation = @ParentHubNameVariation, 
			ParentHubID = @ParentHubID, 
			ChildHubID = @ChildHubID, 
			UpdatedDT = @TransactionDT
			WHERE PKFKLinkID = @PKFKLinkID
		END
	
	--delete record
	
	IF @TransactionAction = 'Delete'
	
		BEGIN
			--set record status inactive = 0 (soft delete record)
			Update [DMOD].[PKFKLink] 
			SET IsActive = 0, 
			UpdatedDT = @TransactionDT
			WHERE PKFKLinkID = @PKFKLinkID

			--set fields for link name inactive
			Update [DMOD].[PKFKLinkField]
			SET IsActive = 0
			WHERE PKFKLinkID = @PKFKLinkID
		END

END


GO
