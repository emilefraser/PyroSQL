SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      RJ Oosthuizen
-- Create Date: 30/05/2019
-- Description: Manage Satellites
-- =============================================
CREATE PROCEDURE [APP].[sp_CRUD_Satellite_Name]
(
                @SatelliteID int, -- primary key of the selected satellite
                @HubID int, -- primary key of the selected hub
                @SatelliteName varchar(300), --  name of the satellite
                @SatelliteDataVelocityTypeID int, -- speed of the satellite
    @TransactionAction nvarchar(20) = null, -- type of transaction, "Create", "Delete"
                -- required params, please do not remove
    @TransactionPerson varchar(80), -- who actioned
    @MasterEntity varchar(50), -- from where actioned
                @OUTPUT int OUTPUT -- will output the SatelliteID(Used to create loadconfig)
)
AS
BEGIN

                DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate())  -- date of transaction
                DECLARE @JSONData varchar(max) = null -- to store in audit table
    DECLARE @PrimaryKeyID int = null -- primary key value for the table
    DECLARE @TableName VARCHAR(50) = 'DMOD.Satellite' -- table name


                IF @TransactionAction = 'Create'
                
                
                                BEGIN
                                                --insert new hub into hub table
                                                INSERT INTO [DMOD].[Satellite] (HubID, SatelliteName, SatelliteDataVelocityTypeID, IsDetailTransactionLinkSat, CreatedDT, IsActive)
                                                VALUES(@HubID, @SatelliteName, @SatelliteDataVelocityTypeID, 0, @TransactionDT, 1)

                                                SET @SatelliteID = SCOPE_IDENTITY()
                                END

                IF @TransactionAction = 'Update'
                
                
                                BEGIN
                                                --Set InActive
                                                UPDATE [DMOD].[Satellite] 
                                                SET SatelliteName = @SatelliteName,
                                                SatelliteDataVelocityTypeID = @SatelliteDataVelocityTypeID,
                                                UpdatedDT = @TransactionDT
                                                WHERE SatelliteID = @SatelliteID

                                                SET @PrimaryKeyID = @SatelliteID
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

                                                SET @PrimaryKeyID = @SatelliteID
                                END
                
                IF @TransactionAction = 'UnDelete'
                                BEGIN
                                                --Set InActive for header
                                                UPDATE [DMOD].[Satellite] 
                                                SET IsActive = 1
                                                WHERE SatelliteID = @SatelliteID

                                                SET @PrimaryKeyID = @SatelliteID
                                END

                SET @OUTPUT = @SatelliteID
                SELECT @OUTPUT

                      
 SET @JSONData = (SELECT * FROM [DMOD].[Satellite]
WHERE SatelliteID = @PrimaryKeyID
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES )

--call sp to store json audit data in table

EXEC [APP].sp_Audit_Trail_Insert @TransactionPerson = @TransactionPerson,
@TransactionAction = @TransactionAction,
@MasterEntity = @MasterEntity,
@JSONData = @JSONData,
@TransactionDT = @TransactionDT,
@PrimaryKeyID = @PrimaryKeyID,
@TableName = @TableName
END

GO
