SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [APP].[sp_CRUD_SortOrder_Value]
(
	@SortOrderValueID int, --not needed for Create
	@SortOrder int, -- ranking
	@DataValue varchar(100), -- display name
	@SortOrderGroupingID varchar(50), -- header primary key
	@TransactionPerson varchar(80), -- who actioned
    @MasterEntity varchar(50), -- from where actioned
    @TransactionAction nvarchar(20) = '' -- type of action, "Create", "Update", "Delete"
)
AS

BEGIN
    DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction
    DECLARE @isActive bit --indicate soft delete
    DECLARE @JSONData varchar(max) = null -- to store in audit table
    DECLARE @PrimaryKeyID int = null -- primary key value for the table
    DECLARE @TableName VARCHAR(50) = 'MASTER.SortOrderValue' -- table name

	--create record
    IF @TransactionAction = 'Create'
        BEGIN
		    --Insert new record
            INSERT INTO MASTER.SortOrderValue (SortOrderGroupingID, SortOrder, DataValue, CreatedDT, IsActive)
            VALUES(@SortOrderGroupingID, @SortOrder, @DataValue, @TransactionDT, 1)
            
			--get primary key value to store in audit table)
            --SET @PrimaryKeyID = (SELECT SortOrderValueID 
            --                    FROM MASTER.SortOrderValue 
            --                    WHERE SortOrderGroupingID = @SortOrderGroupingID 
            --                    AND SortOrder = @SortOrder 
            --                    AND DataValue = @Datavalue)
			SET @PrimaryKeyID = (SELECT SortOrderValueID FROM MASTER.SortOrderValue WHERE CreatedDT = @TransactionDT)
        END

    --update record
    IF @TransactionAction = 'Update'
        BEGIN
            --update existing record
			Update [MASTER].[SortOrderValue] 
			SET SortOrder = @SortOrder,
			UpdatedDT = @TransactionDT
			WHERE SortOrderValueID =  @SortOrderValueID

			--get primary key value to store in audit table
			SET @PrimaryKeyID = @SortOrderValueID
        END

    --delete record
    IF @TransactionAction = 'Delete'
        BEGIN           
            --set record status inactive = 0 (delete record)
			UPDATE MASTER.SortOrderValue 
			SET IsActive = 0,
            UpdatedDT = @TransactionDT
			WHERE SortOrderValueID = @SortOrderValueID

			--get primary key value to store in audit table
            SET @PrimaryKeyID = @SortOrderValueID
        END
        
		--capture json data
					SET @JSONData = (SELECT SortOrder,DataValue,CreatedDT,UpdatedDT,IsActive
                            FROM MASTER.SortOrderValue 
                            WHERE SortOrderValueID = @PrimaryKeyID
                            FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER )

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
