SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      RJ Oosthuizen
-- Create Date: 30/05/2019
-- Description: Manage hub and business key links
-- =============================================
CREATE PROCEDURE [APP].[sp_CRUD_PKFK_Link_Name]
(
   @PKFKLinkID int, --primary key
   @ParentHubNameVariation varchar(150),
   @ParentHubID int, --PK Hub ID
   @ChildHubID int, --FK Hub ID
   @LinkName varchar(200), --name of link
   @TransactionPerson varchar(80), -- who actioned
   @MasterEntity varchar(50), -- from where actioned
   @TransactionAction nvarchar(20) = null -- type of transaction, "Create", "Delete"
)
AS
BEGIN
    DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate())  -- date of transaction
    DECLARE @JSONData varchar(max) = null -- to store in audit table
    DECLARE @PrimaryKeyID int = null -- primary key value for the table
    DECLARE @TableName VARCHAR(50) = 'DMOD.PKFKLink' -- table name
    SET @ParentHubNameVariation = NULLIF(@ParentHubNameVariation, '')
    ----get pk and fk hub name
    --DECLARE @PKHubName varchar(200) = (SELECT TOP 1 HubName 
    --                                  FROM DMOD.Hub 
    --                                  WHERE HubID = @ParentHubID)
    --DECLARE @FKHubName varchar(200) = (SELECT TOP 1 HubName 
    --                                  FROM DMOD.Hub 
    --                                  WHERE HubID = @ChildHubID)
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
            SET @PrimaryKeyID = SCOPE_IDENTITY()
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

            SET @PrimaryKeyID = @PKFKLinkID
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

            SET @PrimaryKeyID = @PKFKLinkID
        END

    SET @JSONData = (SELECT * FROM [DMOD].[PKFKLink]
    WHERE PKFKLinkID = @PrimaryKeyID
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
