SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE [APP].[sp_CRUD_DMOD_Load_Config](

                --all table fields, remove the ones you dont need
                @LoadConfigID int, -- primary key table 1
                @LoadTypeID int,
                @SourceDataEntityID int,
                @IsSetForReloadOnNextRun bit,
                @OffsetDays int,
                @CreatedDTField varchar(50),
                @UpdatedDTField varchar(50),
                -- required params, please do not remove
                @TransactionPerson varchar(80), -- who actioned
                @MasterEntity varchar(50), -- from where actioned
                @TransactionAction nvarchar(20) = null, -- type of transaction, "Create", "Update", "Delete"
                @HubOrSat nvarchar(20) = null, -- will indicate if it is a config for a Hub or a Satellite
                @HubOrSatPrimaryKeyID int -- The primary key of the Hub or Satellite
)
AS
BEGIN

                DECLARE @TransactionDT datetime2(7) =[MASTER].[udf_Convert_Date_To_UTC](getDate())  -- date of transaction
                DECLARE @JSONData varchar(max) = null -- to store in audit table
                DECLARE @PrimaryKeyID int = null -- primary key value for the table
                DECLARE @TableName VARCHAR(50) = 'DMOD.LoadConfig' -- table name


                --change vars for int to null
                --only in cases where the other variable has a value and these ones needs a null
                IF @LoadConfigID = -1
                                BEGIN
                                                SET @LoadConfigID = NULL
                                END
                IF @CreatedDTField = -1
                                BEGIN
                                                SET @CreatedDTField = NULL
                                END
                IF @UpdatedDTField = -1
                                BEGIN
                                                SET @UpdatedDTField = NULL
                                END
                IF @OffsetDays = -1
                                BEGIN
                                                SET @OffsetDays = NULL
                                END
                

                                --update record --DO BEFORE INSERT TO CHECK IF ALREADY EXISTS
                IF @TransactionAction = 'Update'
                                BEGIN
                                                IF @LoadConfigID = NULL --means a satellite name exists but with no load
                                                                BEGIN
                                                                                SET @TransactionAction = 'Create' --will create in stead of update load because it does not exist
                                                                END
                                                ELSE
                                                                BEGIN
                                                                                --update existing record
                                                                                UPDATE DMOD.LoadConfig
                                                                                SET LoadTypeID = @LoadTypeID,
                                                                                SourceDataEntityID = @SourceDataEntityID,
                                                                                IsSetForReloadOnNextRun = @IsSetForReloadOnNextRun,
                                                                                OffsetDays = @OffsetDays,
                                                                                CreatedDT_FieldID = @CreatedDTField,
                                                                                UpdatedDT_FieldID = @UpdatedDTField,
                                                                                UpdatedDT = @TransactionDT
                                                                                WHERE LoadConfigID = @LoadConfigID

                                                                                SET @PrimaryKeyID = @LoadConfigID -- for auditing, get id
                                                                END
                                END

                --create record
                IF @TransactionAction = 'Create'
                                BEGIN
                                                --Insert new record
                                                --remove fields not needed, keep CreatedDT and IsActive
                                                INSERT INTO DMOD.LoadConfig(LoadTypeID, SourceDataEntityID, IsSetForReloadOnNextRun, OffsetDays, CreatedDT_FieldID, UpdatedDT_FieldID, CreatedDT, IsActive)
                                                VALUES(@LoadTypeID, @SourceDataEntityID, @IsSetForReloadOnNextRun, @OffsetDays, @CreatedDTField, @UpdatedDTField, @TransactionDT, 1)                                            

                                                SET @PrimaryKeyID = SCOPE_IDENTITY()  -- for auditing, get id
                
                                END

                --delete record
                IF @TransactionAction = 'Delete'
                                BEGIN
                                                IF @LoadConfigID != NULL
                                                                BEGIN
                                                                                --set record status inactive = 0 (soft delete record)
                                                                                UPDATE DMOD.LoadConfig
                                                                                SET IsActive = 0,
                                                                                UpdatedDT = @TransactionDT
                                                                                WHERE LoadConfigID = @LoadConfigID

                                                                                SET @PrimaryKeyID = @LoadConfigID -- for auditing, get id
                                                                END
                                END

                --reload option for record
                IF @TransactionAction = 'Reload'
                                BEGIN
                                                --set record status for reload (0 or 1)
                                                Update DMOD.LoadConfig 
                                                SET IsSetForReloadOnNextRun = @IsSetForReloadOnNextRun, 
                                                UpdatedDT = @TransactionDT
                                                WHERE LoadConfigID = @LoadConfigID

                                                SET @PrimaryKeyID = @LoadConfigID -- for auditing, get id
                                END

                -- REMOVE AND CHANGE TO REACTIVATE FUNCTION ONCE AUDITING FOR THIS PROC WORKS
                IF @TransactionAction = 'UnDelete'
                                BEGIN
                                                IF @LoadConfigID != NULL
                                                                BEGIN
                                                                                --set record status inactive = 0 (soft delete record)
                                                                                UPDATE DMOD.LoadConfig
                                                                                SET IsActive = 1,
                                                                                UpdatedDT = @TransactionDT
                                                                                WHERE LoadConfigID = @LoadConfigID

                                                                                SET @PrimaryKeyID = @LoadConfigID -- for auditing, get id
                                                                END
                                END

                                --insert into M2M table if does not exist for hubs
                IF @HubOrSat = 'Hub'
                                BEGIN
                                                IF((SELECT COUNT(*) FROM DMOD.HubLoadConfig WHERE HubID = @HubOrSatPrimaryKeyID AND SourceDataEntityID = @SourceDataEntityID) = 0)
                                                                BEGIN
                                                                                INSERT INTO DMOD.HubLoadConfig(HubID, SourceDataEntityID, LoadConfigID)
                                                                                VALUES(@HubOrSatPrimaryKeyID, @SourceDataEntityID, @PrimaryKeyID)
                                                                END

                                END

                --insert into M2M table if does not exist for sats
                IF @HubOrSat = 'Satellite'
                BEGIN
                                IF((SELECT COUNT(*) FROM DMOD.SatelliteLoadConfig WHERE SatelliteID = @HubOrSatPrimaryKeyID AND LoadConfigID = @LoadConfigID) = 0)
                                                BEGIN
                                                                INSERT INTO DMOD.SatelliteLoadConfig(SatelliteID, SourceDataEntityID, LoadConfigID)
                                                                VALUES(@HubOrSatPrimaryKeyID, @SourceDataEntityID, @PrimaryKeyID)
                                                END
                                ELSE
                                                BEGIN
                                                                UPDATE DMOD.SatelliteLoadConfig
                                                                SET SourceDataEntityID = @SourceDataEntityID
                                                                WHERE SatelliteID = @HubOrSatPrimaryKeyID AND LoadConfigID = @LoadConfigID
                                                END
                END
END

GO
