SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      RJ Oosthuizen
-- Create Date: 30/05/2019
-- Description: Manage hubs
-- =============================================
CREATE PROCEDURE [APP].[sp_CRUD_Hub]
(
    @HubID int, -- primary key of the selected hub
    @HubName varchar(200), -- name of the selected hub
    @has_linking_table bit, --determines if DDID needs to be linked directly to table or linking table
    @DataDomainID INT,
    @IsReferenceHub bit,
    @LinkingTableName varchar(max), -- The table that is linking with the Master Entity - Main Table 
    @LinkingTableItemColumnName varchar(max), -- the column that should become linked
    @ItemPrimaryKeyColumnName varchar(max), -- Primary column of the table where Item is in
    @TransactionPerson varchar(80), -- who actioned
    @MasterEntity varchar(50), -- from where actioned
    @TransactionAction nvarchar(20) = null, -- type of transaction, "Create", "Delete"
    @OUTPUT int OUTPUT -- will output the HubID(Used to create loadconfig)
)
AS
BEGIN
    DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate())  -- date of transaction
    DECLARE @JSONData varchar(max) = null -- to store in audit table
    DECLARE @PrimaryKeyID int = null -- primary key value for the table
    DECLARE @TableName VARCHAR(50) = 'DMOD.Hub' -- table name
    IF @TransactionAction = 'Create'
        BEGIN
        IF EXISTS (SELECT 1 FROM [DMOD].[Hub] WHERE @HubName = HubName)
        BEGIN 
            SELECT 'Already Exist'
       END
            ELSE
            --insert new hub into hub table
            INSERT INTO [DMOD].[Hub] (HubName, IsReferenceHub, DataDomainID, CreatedDT, IsActive)
            VALUES(@HubName, @IsReferenceHub, @DataDomainID, @TransactionDT, 1)
            SET @PrimaryKeyID = SCOPE_IDENTITY() 
        END
    IF @TransactionAction = 'Update'
        BEGIN
            --Set InActive
            UPDATE [DMOD].[Hub] 
            SET HubName = @HubName,
            DataDomainID = @DataDomainID,
            IsReferenceHub = @IsReferenceHub 
            WHERE HubID = @HubID

            SET @PrimaryKeyID = @HubID
        END
    IF @TransactionAction = 'Delete'
        BEGIN
            --Set InActive
            UPDATE [DMOD].[Hub] 
            SET IsActive = 0
            WHERE HubID = @HubID
            
                                                SET @PrimaryKeyID = @HubID
        END
    IF @TransactionAction = 'UnDelete'
        BEGIN
            --Set InActive
            UPDATE [DMOD].[Hub] 
            SET IsActive = 1
            WHERE HubID = @HubID

            SET @PrimaryKeyID = @HubID
        END
    --Link Data Domain to item
    EXEC [APP].[sp_Link_DataDomain_And_Item] @has_linking_table, @DataDomainID, @MasterEntity, @LinkingTableName, @LinkingTableItemColumnName, HubID, @ItemPrimaryKeyColumnName OUTPUT
    SET @OUTPUT = @HubID
    SELECT @OUTPUT

    SET @JSONData = (SELECT * FROM [DMOD].[Hub] 
    WHERE HubID = @PrimaryKeyID
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
