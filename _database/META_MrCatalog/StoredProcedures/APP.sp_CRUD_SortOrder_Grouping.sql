SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [APP].[sp_CRUD_SortOrder_Grouping](
	@SortOrderGroupName varchar(100), -- name of sort order
	@SortOrderGroupCode varchar(50), -- unique
	@FieldID int, -- fields from DC.Fields
	@TransactionPerson varchar(80), -- who actioned
    @MasterEntity varchar(50), -- from where actioned
    @TransactionAction nvarchar(20) = '' -- type of transaction, "Create", "Update", "Delete"
    )
AS

BEGIN

    DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate())  -- date of transaction
    DECLARE @JSONData varchar(max) = null -- to store in audit table
    DECLARE @PrimaryKeyID int = null -- primary key value for the table
    DECLARE @TableName VARCHAR(50) = 'MASTER.SortOrderGrouping' -- table name
    
    --create record
    IF @TransactionAction = 'Create'
        BEGIN
            --check if record exists
            IF EXISTS (SELECT 1 FROM MASTER.SortOrderGrouping WHERE  @SortOrderGroupCode = SortOrderGroupCode)
	            BEGIN
		            SELECT 'Already Exist'
	            END
	        ELSE
    	        BEGIN
                    --Insert new record
	                INSERT INTO MASTER.SortOrderGrouping (SortOrderGroupName,SortOrderGroupCode,FieldID,CreatedDT, IsActive)
	                VALUES(@SortOrderGroupName,@SortOrderGroupCode,@FieldID,@TransactionDT, 1)
                END
        END

    --update record
    IF @TransactionAction = 'Update'
        BEGIN
            --check if record exists
    		IF EXISTS (SELECT 1 FROM MASTER.SortOrderGrouping WHERE  @SortOrderGroupCode = SortOrderGroupCode)
                BEGIN
                    --update existing record
                    UPDATE MASTER.SortOrderGrouping 
                    SET SortOrderGroupName = @SortOrderGroupName, 
					UpdatedDT = @TransactionDT
			        WHERE SortOrderGroupCode = @SortOrderGroupCode
                END
        END
    --delete record
    IF @TransactionAction = 'Delete'
        BEGIN            
            --set record status inactive = 0 (soft delete record)
            Update MASTER.SortOrderGrouping 
	        SET IsActive = 0, UpdatedDT = @TransactionDT
		    WHERE SortOrderGroupCode = @SortOrderGroupCode
        END
        

	--capture json data (get primary key value to store in audit table)
    SET @PrimaryKeyID = (SELECT SortOrderGroupingID FROM MASTER.SortOrderGrouping WHERE SortOrderGroupCode = @SortOrderGroupCode)
    SET @JSONData = (SELECT  SortOrderGroupName,SortOrderGroupCode,CreatedDT,UpdatedDT,IsActive
                     FROM MASTER.SortOrderGrouping 
                     WHERE SortOrderGroupCode = @SortOrderGroupCode
                     FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES)

    --call sp to store json audit data in table
    EXEC [APP].sp_Audit_Trail_Insert @TransactionPerson = @TransactionPerson, 
                                    @TransactionAction = @TransactionAction, 
                                    @MasterEntity = @MasterEntity, 
                                    @JSONData = @JSONData, 
                                    @TransactionDT = @TransactionDT, 
                                    @PrimaryKeyID = @PrimaryKeyID, 
                                    @TableName = @TableName

	--check for existing sort order values
	--EXEC [INTEGRATION].sp_load_DistinctSortOrderValues @FieldID = @FieldID,
	--												@SortOrderGroupingID = @PrimaryKeyID,
	--												@TransactionPerson = @TransactionPerson

END

GO
