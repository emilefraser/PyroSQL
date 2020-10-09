SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      RJ Oosthuizen
-- Create Date: 30/05/2019
-- Description: Manage hubs
-- =============================================
CREATE PROCEDURE [APP].[sp_CRUD_Hub_Internal]
(
	@HubID int, -- primary key of the selected hub
	@HubName varchar(200), -- name of the selected hub
	@IsReferenceHub bit,
    @TransactionAction nvarchar(20) = null, -- type of transaction, "Create", "Delete"
	@TransactionPerson varchar(80), -- who actioned
    @MasterEntity varchar(50) -- from where actioned
)
AS
BEGIN

	DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction

	IF @TransactionAction = 'Create'
	
	
		BEGIN
			--insert new hub into hub table
			INSERT INTO [DMOD].[Hub] (HubName, IsReferenceHub, CreatedDT, IsActive)
			VALUES(@HubName, @IsReferenceHub, @TransactionDT, 1)
		END

	IF @TransactionAction = 'Update'
	
	
		BEGIN
			--Set InActive
			UPDATE [DMOD].[Hub] 
			SET HubName = @HubName,
			IsReferenceHub = @IsReferenceHub 
			WHERE HubID = @HubID
		END

	IF @TransactionAction = 'Delete'
	
	
		BEGIN
			--Set InActive
			UPDATE [DMOD].[Hub] 
			SET IsActive = 0
			WHERE HubID = @HubID
		END

END

GO
