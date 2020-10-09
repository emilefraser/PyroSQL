SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      RJ Oosthuizen
-- Create Date: 30/05/2019
-- Description: Manage business key fields
-- =============================================
CREATE PROCEDURE [APP].[sp_CRUD_BK_Field]
(
    @HubBusinessKeyID int, -- header id of hub businesskey table
    @NewSourceFieldID int, --selected field id(for new and update)
    @CurrentSourceFieldID int,--for update and delete
    @IsBaseEntityField bit,
    @TransactionPerson varchar(80), -- who actioned
    @MasterEntity varchar(50), -- from where actioned
    @TransactionAction nvarchar(20) = null -- type of transaction, "Create", "Delete"
)
AS
BEGIN
    DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate()) -- date of transaction
    DECLARE @JSONData varchar(max) = null -- to store in audit table
    DECLARE @PrimaryKeyID int = null -- primary key value for the table
    DECLARE @TableName VARCHAR(50) = '[DMOD].[HubBusinessKeyField]' -- table name
    --create record
    IF @TransactionAction = 'Create'
        BEGIN
            DECLARE @HubBusinessKeyIDCompare INT --hubbkid to compare to provided hubbkid
            DECLARE @NewSourceFieldIDCompare INT --fieldid to compare to provided fieldid
            DECLARE @IsFound INT = 0 --if 0 then will do an insert(so create entry), if 1 then will only update(set isactive = 1 for that combination)
            DECLARE BKField_cursor CURSOR FOR   --declare cursor
                SELECT HubBusinessKeyID, FieldID
                FROM [DMOD].[HubBusinessKeyField] AS hbkf --get data from this table to compare to provided vars
                OPEN BKField_cursor  
                FETCH NEXT FROM BKField_cursor   --initial fetch(DO-While statement)
                INTO @HubBusinessKeyIDCompare, @NewSourceFieldIDCompare
            WHILE @@FETCH_STATUS = 0  
                BEGIN  
                    IF(@HubBusinessKeyID = @HubBusinessKeyIDCompare AND @NewSourceFieldID = @NewSourceFieldIDCompare) --if comparison is met
                        BEGIN
                            SET @IsFound = 1 --now wont update
                            UPDATE [DMOD].[HubBusinessKeyField]
                            SET IsActive = 1,
                            UpdatedDT = @TransactionDT,
                            IsBaseEntityField = @IsBaseEntityField
                            WHERE HubBusinessKeyID = @HubBusinessKeyID
                            AND FieldID = @NewSourceFieldID
                            BREAK; -- break from loop once condition is met
                        END
                    FETCH NEXT FROM BKField_cursor   
                    INTO @HubBusinessKeyIDCompare, @NewSourceFieldIDCompare --while fetch
                END   
            CLOSE BKField_cursor;  
            DEALLOCATE BKField_cursor;  
            If(@IsFound = 0) --nothing has been found so insert will commence
                BEGIN
                    --Insert new record into hub bk
                    INSERT INTO [DMOD].[HubBusinessKeyField] (HubBusinessKeyID, FieldID, IsBaseEntityField, CreatedDT, IsActive)
                    VALUES (@HubBusinessKeyID, @NewSourceFieldID, @IsBaseEntityField, @TransactionDT, 1)
                    SET @PrimaryKeyID = SCOPE_IDENTITY() 
                END
        END
    --update record
    IF @TransactionAction = 'Update'
        BEGIN
            --set record status inactive = 0 (soft delete record)
            Update [DMOD].[HubBusinessKeyField] 
            SET FieldID = @NewSourceFieldID,
            IsBaseEntityField = @IsBaseEntityField,
            UpdatedDT = @TransactionDT
            WHERE HubBusinessKeyID = @HubBusinessKeyID
            AND FieldID = @CurrentSourceFieldID

            SET @PrimaryKeyID = @HubBusinessKeyID
        END
    --delete record
    IF @TransactionAction = 'Delete'
        BEGIN
            --set record status inactive = 0 (soft delete record)
            Update [DMOD].[HubBusinessKeyField] 
            SET IsActive = 0, 
            UpdatedDT = @TransactionDT
            WHERE HubBusinessKeyID = @HubBusinessKeyID
            AND FieldID = @CurrentSourceFieldID

            SET @PrimaryKeyID = @HubBusinessKeyID
        END
    --reactivate link   
    IF @TransactionAction = 'UnDelete'
        BEGIN
            --set record status inactive = 1
            Update [DMOD].[HubBusinessKeyField] 
            SET IsActive = 1, 
            UpdatedDT = @TransactionDT
            WHERE HubBusinessKeyID = @HubBusinessKeyID
            AND FieldID = @CurrentSourceFieldID

            SET @PrimaryKeyID = @HubBusinessKeyID
        END

    SET @JSONData = (SELECT * FROM [DMOD].[HubBusinessKeyField] 
    WHERE HubBusinessKeyFieldID = @PrimaryKeyID
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
