SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [APP].[sp_CRUD_Reporting_Hierarchy_Item](

--all table fields, remove the ones you dont need
@CompanyID int,
@ItemCode varchar(50),
@ItemName varchar(100),
@ParentItemID  int,
@ReportingHierarchySortOrder int,
@ReportingHierarchyTypeID int,
@NewParentItemID int, -- the reporting hierarchy item id you want to assign to
-- required params, please do not remove
@TransactionPerson varchar(80), -- who actioned
@MasterEntity varchar(50), -- from where actioned
@TransactionAction nvarchar(20) = null -- type of transaction, "Create", "Update", "Delete"
)
AS
BEGIN
DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate())  -- date of transaction
DECLARE @isActive bit -- indicate soft delete
DECLARE @JSONData varchar(max) = null -- to store in audit table
DECLARE @PrimaryKeyID int = null -- primary key value for the table
DECLARE @TableName VARCHAR(50) = 'MASTER.ReportingHierarchyItem' -- table name
DECLARE @ReportingHierarchyItemID int = (SELECT ReportingHierarchyItemID FROM MASTER.ReportingHierarchyItem WHERE  @ItemCode = ItemCode)
DECLARE @Treepath varchar(MAX) = (SELECT Treepath from [MASTER].[vw_BuildTreePathForReportingHierarchyItem] where @ReportingHierarchyItemID = ReportingHierarchyItemID)

	--test bench
	--DECLARE @ItemName varchar(50) = 'TestName'
	--DECLARE @ReportingHierarchyTypeID int = 0
	--DECLARE @CompanyID int = 0
	--DECLARE @ParentItemID int = 0
	--DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction
	--DECLARE @JSONData varchar(max) = null -- to store in audit table
	--DECLARE @PrimaryKeyID int = null -- primary key value for the table
	--DECLARE @TransactionAction varchar(20) = 'Update'
	--DECLARE @MasterEntity varchar(50) = 'testEntity'
	--DECLARE @TableName varchar(50) = 'TestTable'
	--DECLARE @TransactionPerson varchar(50) = 'TestUser' -- who actioned
	--DECLARE @ItemCode varchar(50) = 'RJRJRJ'
	--DECLARE @ReportingHierarchySortOrder int = 98
	--DECLARE @ReportingHierarchyItemID int = (SELECT ReportingHierarchyItemID FROM MASTER.ReportingHierarchyItem WHERE  @ItemCode = ItemCode)
 --   DECLARE @Treepath varchar(MAX) = (SELECT Treepath from [MASTER].[vw_BuildTreePathForReportingHierarchyItem] where @ReportingHierarchyItemID = ReportingHierarchyItemID)

--create record
IF @TransactionAction = 'Create'
    BEGIN
            BEGIN
                --Insert new record
                --remove fields not needed, keep CreatedDT and IsActive
                --if parent = 0 then top parent
                IF(@ParentItemID = 0)
                    BEGIN
                        INSERT INTO MASTER.ReportingHierarchyItem (CompanyID, CreatedDT, ItemCode, ItemName, ReportingHierarchySortOrder, ReportingHierarchyTypeID,  IsActive)
                        VALUES(@CompanyID, @TransactionDT, @ItemCode, @ItemName, @ReportingHierarchySortOrder, @ReportingHierarchyTypeID,  1)
                    END
                --if parent not null then add to parent above
                ELSE
                    BEGIN
                        INSERT INTO MASTER.ReportingHierarchyItem (CompanyID, CreatedDT, ItemCode, ItemName, ParentItemID, ReportingHierarchySortOrder, ReportingHierarchyTypeID,  IsActive)
                        VALUES(@CompanyID, @TransactionDT, @ItemCode, @ItemName, @ParentItemID, @ReportingHierarchySortOrder, @ReportingHierarchyTypeID,  1)
                    END

				SET @PrimaryKeyID = SCOPE_IDENTITY()
                
				--create link entry
                INSERT INTO [MASTER].[LinkReportingHierarchyItemToBKCombination] (ReportingHierarchyItemID)
                VALUES (SCOPE_IDENTITY())

            
            END
    END
--update record
IF @TransactionAction = 'Update'
    BEGIN
        --check if record exists
        IF EXISTS (SELECT 1 FROM MASTER.ReportingHierarchyItem WHERE  @ItemCode = ItemCode)
            BEGIN
                --update existing record
                UPDATE MASTER.ReportingHierarchyItem 
                --remove fields not needed, keep UpdatedDT
                SET
                ReportingHierarchySortOrder = @ReportingHierarchySortOrder,
                UpdatedDT = @TransactionDT
                WHERE ItemCode = @ItemCode
                SET @PrimaryKeyID = (SELECT ReportingHierarchyItemID FROM MASTER.ReportingHierarchyItem WHERE ItemCode = @ItemCode)
            END
    END
----delete record
IF @TransactionAction = 'Delete'
    BEGIN
        --set record status inactive = 0 (soft delete record)
        Update MASTER.ReportingHierarchyItem 
        SET IsActive = 0, 
        UpdatedDT = @TransactionDT
        WHERE ReportingHierarchyItemID IN (SELECT ReportingHierarchyItemID FROM [MASTER].[vw_BuildTreePathForReportingHierarchyItem] WHERE treepath like '%' + @TreePath + '%')
		
		SET @PrimaryKeyID =  @ReportingHierarchyItemID
    END

IF @TransactionAction = 'Reassign'
	BEGIN
		Update MASTER.ReportingHierarchyItem 
        --SET IsActive = 1,
        SET UpdatedDT = @TransactionDT,
		ParentitemID = @NewParentItemID
        WHERE ReportingHierarchyItemID = @ReportingHierarchyItemID --IN (SELECT ReportingHierarchyItemID FROM [MASTER].[vw_BuildTreePathForReportingHierarchyItem] WHERE treepath like '%' + @Treepath + '%')
		
		SET @PrimaryKeyID = @ReportingHierarchyItemID
	END
	--ReactivateTopParent
IF @TransactionAction = 'Reactivate'
	BEGIN
		--Set all nodes in treepath active first
		Update MASTER.ReportingHierarchyItem 
        SET IsActive = 1,
        UpdatedDT = @TransactionDT
        WHERE ReportingHierarchyItemID IN (SELECT ReportingHierarchyItemID FROM [MASTER].[vw_BuildTreePathForReportingHierarchyItem] WHERE treepath like '%' + @Treepath + '%')

		--Update Parent id for top node in treepath, assign to the node that the user wants to reactivate to
		Update MASTER.ReportingHierarchyItem 
		SET ParentitemID = @NewParentItemID
		WHERE ReportingHierarchyItemID = @ReportingHierarchyItemID

		SET @PrimaryKeyID =  @ReportingHierarchyItemID
	END
	
	IF @TransactionAction = 'ReactivateTopParent'
	BEGIN
		--Set all nodes in treepath active first
		Update MASTER.ReportingHierarchyItem 
        SET IsActive = 1,
        UpdatedDT = @TransactionDT
        WHERE ReportingHierarchyItemID IN (SELECT ReportingHierarchyItemID FROM [MASTER].[vw_BuildTreePathForReportingHierarchyItem] WHERE treepath like '%' + @Treepath + '%')

		--Update Parent id for top node in treepath, assign to the node that the user wants to reactivate to
		Update MASTER.ReportingHierarchyItem 
		SET ParentitemID = NULL
		WHERE ReportingHierarchyItemID = @ReportingHierarchyItemID

		SET @PrimaryKeyID =  @ReportingHierarchyItemID
	END

	SET @TreePath = (SELECT Treepath from [MASTER].[vw_BuildTreePathForReportingHierarchyItem] where ReportingHierarchyItemID = @PrimaryKeyID)


    DECLARE @AuditRecordTable Table
    (
		RowNumber int IDENTITY(1,1),
	    PrimaryKeyID int,
		JSONData varchar(max)
    )

    INSERT INTO @AuditRecordTable (
	PrimaryKeyID,
	JSONData
    )
    SELECT
	ReportingHierarchyItemID,
	(SELECT CompanyID,
	ItemCode,
	ItemName,
	ParentItemID,
	SortOrder,
	ReportingHierarchyTypeID,
	CreatedDT,
	UpdatedDT,
	IsActive
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER,INCLUDE_NULL_VALUES
	)
	FROM [MASTER].[vw_BuildTreePathForReportingHierarchyItem]
	WHERE ReportingHierarchyItemID IN (SELECT ReportingHierarchyItemID FROM [MASTER].[vw_BuildTreePathForReportingHierarchyItem] WHERE treepath like '%' + @TreePath + '%')

	select * from @AuditRecordTable

	DECLARE @RowCount int = 1
	DECLARE @MaxRows int  = (SELECT COUNT(*) FROM @AuditRecordTable)

	WHILE @RowCount <= @MaxRows
		BEGIN
			SET @JSONData = (SELECT JSONData FROM @AuditRecordTable WHERE RowNumber = @RowCount)
			SET @PrimaryKeyID = (SELECT PrimaryKeyID FROM @AuditRecordTable WHERE RowNumber = @RowCount)

			EXEC [APP].sp_Audit_Trail_Insert @TransactionPerson = @TransactionPerson,
			@TransactionAction = @TransactionAction,
			@MasterEntity = @MasterEntity,
			@JSONData = @JSONData,
			@TransactionDT = @TransactionDT,
			@PrimaryKeyID = @PrimaryKeyID,
			@TableName = @TableName

			SET @RowCount = @RowCount + 1
		END
END

GO
