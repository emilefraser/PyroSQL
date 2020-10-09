SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      RJ Oosthuizen
-- Create Date: 30/05/2019
-- Description: Manage Satellites
-- =============================================
CREATE PROCEDURE [APP].[sp_CRUD_Satellite_Name_Internal]
(
	@SatelliteID int, -- primary key of the selected satellite
	@HubID int, -- primary key of the selected hub
	@SatelliteName varchar(300), --  name of the satellite
	@SatelliteDataVelocityTypeID int, -- speed of the satellite
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
			INSERT INTO [DMOD].[Satellite] (HubID, SatelliteName, SatelliteDataVelocityTypeID, IsDetailTransactionLinkSat, CreatedDT, IsActive)
			VALUES(@HubID, @SatelliteName, @SatelliteDataVelocityTypeID, 0, @TransactionDT, 1)
		END

	IF @TransactionAction = 'Update'
	
	
		BEGIN
			--Set InActive
			UPDATE [DMOD].[Satellite] 
			SET SatelliteName = @SatelliteName,
			SatelliteDataVelocityTypeID = @SatelliteDataVelocityTypeID,
			UpdatedDT = @TransactionDT
			WHERE SatelliteID = @SatelliteID
		END

	IF @TransactionAction = 'Delete'
	
	
		BEGIN
			--Set InActive for header
			UPDATE [DMOD].[Satellite] 
			SET IsActive = 0
			WHERE SatelliteID = @SatelliteID
		
			--set inactive for detail
			UPDATE [DMOD].[SatelliteField]
			SET IsActive = 0
			WHERE SatelliteID = @SatelliteID
		END

END

GO
