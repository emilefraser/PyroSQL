SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      RJ Oosthuizen
-- Create Date: 30/05/2019
-- Description: Manage hub and business key links
-- =============================================
CREATE PROCEDURE [APP].[sp_CRUD_Hub_BK]
(
   @HubBusinessKeyID int, --primary key
   @HubID int, --primary key of the selected hub
   @FieldSortOrder int, --order of the column of the field in the dataentity
   @BKFriendlyName varchar(200), --friendlyname for the selected field
   @TransactionPerson varchar(80), -- who actioned
   @MasterEntity varchar(50), -- from where actioned
   @TransactionAction nvarchar(20) = null -- type of transaction, "Create", "Delete"
)
AS
BEGIN
    DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate())  -- date of transaction
    DECLARE @JSONData varchar(max) = null -- to store in audit table
    DECLARE @PrimaryKeyID int = null -- primary key value for the table
    DECLARE @TableName VARCHAR(50) = 'DMOD.HubBusinessKey' -- table name
    --create record
    IF @TransactionAction = 'Create'
        BEGIN
            --Insert new record into hub bk
            INSERT INTO [DMOD].[HubBusinessKey] (HubID, FieldSortOrder, BKFriendlyName, CreatedDT, IsActive)
            VALUES (@HubID, @FieldSortOrder, @BKFriendlyName, @TransactionDT, 1)
            SET @PrimaryKeyID = SCOPE_IDENTITY()
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

            SET @PrimaryKeyID = @HubBusinessKeyID
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

            SET @PrimaryKeyID = @HubBusinessKeyID
        END
    SET @JSONData = (SELECT * FROM [DMOD].[HubBusinessKey]
    WHERE HubBusinessKeyID = @PrimaryKeyID
    FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER,INCLUDE_NULL_VALUES)
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
