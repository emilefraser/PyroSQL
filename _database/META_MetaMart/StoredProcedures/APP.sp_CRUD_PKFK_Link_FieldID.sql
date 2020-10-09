SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      RJ Oosthuizen
-- Create Date: 30/05/2019
-- Description: Manage hub and business key links
-- =============================================
CREATE PROCEDURE [APP].[sp_CRUD_PKFK_Link_FieldID]
(
   @PKFKLinkFieldID int, --primary key
   @PKFKLinkID int, --link name primary key
   @PrimaryKeyFieldID int, --PK FieldID
   @ForeignKeyFieldID int, --FK FieldID
   @TransactionPerson varchar(80), -- who actioned
   @MasterEntity varchar(50), -- from where actioned
   @TransactionAction nvarchar(20) = null -- type of transaction, "Create", "Delete"
)
AS
BEGIN
    DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate())  -- date of transaction
    DECLARE @JSONData varchar(max) = null -- to store in audit table
    DECLARE @PrimaryKeyID int = null -- primary key value for the table
    DECLARE @TableName VARCHAR(50) = 'DMOD.PKFKLinkField' -- table name
    --create record
    IF @TransactionAction = 'Create'
        BEGIN
            DECLARE @PKFKLinkIDCompare INT --pkfklinkid to compare to provided pkfklinkid
            DECLARE @PrimaryKeyFieldIDCompare INT --pkfieldid to compare to provided pkfieldid
            DECLARE @ForeignKeyFieldIDCompare INT --fkfieldid to compare to provided fkfieldid
            DECLARE @IsFound INT = 0 --if 0 then will do an insert(so create entry), if 1 then will only update(set isactive = 1 for that combination)
            --this is for when trying to add something and an inactive record is found, it will reactivate that record
            DECLARE PKFKLinkField_cursor CURSOR FOR --declare cursor
                SELECT PKFKLinkID, PrimaryKeyFieldID, ForeignKeyFieldID
                FROM [DMOD].[PKFKLinkField] AS pflf --get data from this table to compare to provided vars
                OPEN PKFKLinkField_cursor  
                FETCH NEXT FROM PKFKLinkField_cursor --initial fetch(DO-While statement)  
                INTO @PKFKLinkIDCompare, @PrimaryKeyFieldIDCompare, @ForeignKeyFieldIDCompare
            WHILE @@FETCH_STATUS = 0  
                BEGIN  
                    --SELECT *
                    --FROM [DMOD].[HubBusinessKeyField] WHERE HubBusinessKeyID = @HubBusinessKeyIDCompare AND FieldID = @NewSourceFieldIDCompare
                    IF(@PKFKLinkID = @PKFKLinkIDCompare AND @PrimaryKeyFieldID = @PrimaryKeyFieldIDCompare AND @ForeignKeyFieldID = @ForeignKeyFieldIDCompare) --if comparison is met
                        BEGIN
                            SET @IsFound = 1 --now wont update
                            UPDATE [DMOD].[PKFKLinkField]
                            SET IsActive = 1,
                            UpdatedDT = @TransactionDT
                            WHERE PKFKLinkID = @PKFKLinkID
                            AND PrimaryKeyFieldID = @PrimaryKeyFieldID
                            AND ForeignKeyFieldID = @ForeignKeyFieldID
                            BREAK; -- break from loop once condition is met
                        END
                    FETCH NEXT FROM PKFKLinkField_cursor   
                    INTO @PKFKLinkIDCompare, @PrimaryKeyFieldIDCompare, @ForeignKeyFieldIDCompare --while fetch
                END   
            CLOSE PKFKLinkField_cursor;  
            DEALLOCATE PKFKLinkField_cursor;  
            If(@IsFound = 0) --nothing has been found so insert will commence
                BEGIN
                    --Insert new record into hub bk
                    INSERT INTO [DMOD].[PKFKLinkField] (PKFKLinkID, PrimaryKeyFieldID, ForeignKeyFieldID, CreatedDT, IsActive)
                    VALUES (@PKFKLinkID, @PrimaryKeyFieldID, @ForeignKeyFieldID, @TransactionDT, 1)
                    SET @PrimaryKeyID = SCOPE_IDENTITY() 
                END
    END
    --Update record
    IF @TransactionAction = 'Update'
        BEGIN
            --Insert new record into hub bk
            UPDATE [DMOD].[PKFKLinkField]
            SET PKFKLinkID = @PKFKLinkID, 
            PrimaryKeyFieldID = @PrimaryKeyFieldID, 
            ForeignKeyFieldID = @ForeignKeyFieldID, 
            UpdatedDT = @TransactionDT
            WHERE PKFKLinkFieldID = @PKFKLinkFieldID

            SET @PrimaryKeyID = @PKFKLinkFieldID 
        END
    --delete record
    IF @TransactionAction = 'Delete'
        BEGIN
            --set record status inactive = 0 (soft delete record)
            Update [DMOD].[PKFKLinkField] 
            SET IsActive = 0, 
            UpdatedDT = @TransactionDT
            WHERE PKFKLinkFieldID = @PKFKLinkFieldID

            SET @PrimaryKeyID = @PKFKLinkFieldID 
        END

    SET @JSONData = (SELECT * FROM [DMOD].[PKFKLinkField] 
    WHERE PKFKLinkFieldID = @PrimaryKeyID
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
