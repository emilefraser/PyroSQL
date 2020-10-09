SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [APP].[sp_CRUD_Reporting_Hierarchy_Type](

--all table fields, remove the ones you dont need

@IsUniqueBKMapping bit,
@ReportingHierarchyDescription varchar(1000),
@ReportingHierarchyTypeCode varchar(10),
@ReportingHierarchyTypeName varchar(100),
@DataDomainID int,
@IsMultipleTopParentAllowed BIT,
-- required params, please do not remove
@TransactionPerson varchar(80), -- who actioned
@MasterEntity varchar(50), -- from where actioned
@TransactionAction nvarchar(20) = null -- type of transaction, "Create", "Update", "Delete"
)

AS

BEGIN

DECLARE @TransactionDT datetime2(7) = getdate() -- date of transaction
DECLARE @isActive bit  -- indicate soft delete
DECLARE @JSONData varchar(max) = null -- to store in audit table
DECLARE @PrimaryKeyID int = null -- primary key value for the table
DECLARE @TableName VARCHAR(50) = 'MASTER.ReportingHierarchyType' -- table name
--DECLARE @ReportingHierarchyTypeID int = (SELECT ReportingHierarchyTypeID FROM MASTER.ReportingHierarchyType WHERE  @ReportingHierarchyTypeCode = ReportingHierarchyTypeCode)
DECLARE @HierarchyLevelsLimit SMALLINT = (SELECT Valueint FROM [DMOD].[ParameterValue] WHERE ParameterID = (SELECT ParameterID FROM [DMOD].[Parameter] WHERE ParameterCode ='HIERARCHYLEVELSLIMIT')) --get hierarchy level limit value
--create record
 
IF @TransactionAction = 'Create'
	BEGIN
		--check if record exists
		IF EXISTS (SELECT 1 FROM MASTER.ReportingHierarchyType WHERE  @ReportingHierarchyTypeCode = ReportingHierarchyTypeCode)
			BEGIN
				SELECT 'Already Exist'
			END
ELSE
	BEGIN
		--Insert new record
		--remove fields not needed, keep CreatedDT and IsActive
		INSERT INTO MASTER.ReportingHierarchyType (CreatedDT, HierarchyLevelsLimit, IsActive, IsUniqueBKMapping, ReportingHierarchyDescription, ReportingHierarchyTypeCode,ReportingHierarchyTypeName,  DataDomainID,IsMultipleTopParentAllowed)
		VALUES(@TransactionDT, @HierarchyLevelsLimit, 1, @IsUniqueBKMapping, @ReportingHierarchyDescription, @ReportingHierarchyTypeCode, @ReportingHierarchyTypeName,  @DataDomainID, @IsMultipleTopParentAllowed)
	END
END

--update record

IF @TransactionAction = 'Update'
	BEGIN
		--check if record exists
		IF EXISTS (SELECT 1 FROM MASTER.ReportingHierarchyType WHERE  @ReportingHierarchyTypeCode = ReportingHierarchyTypeCode)
			BEGIN
				--update existing record
				UPDATE MASTER.ReportingHierarchyType 
				--remove fields not needed, keep UpdatedDT
				SET 
				HierarchyLevelsLimit = @HierarchyLevelsLimit,
				ReportingHierarchyDescription = @ReportingHierarchyDescription,
				ReportingHierarchyTypeName = @ReportingHierarchyTypeName,
				DataDomainID = @DataDomainID,
				IsMultipleTopParentAllowed = @IsMultipleTopParentAllowed,
				UpdatedDT = @TransactionDT
				WHERE ReportingHierarchyTypeCode = @ReportingHierarchyTypeCode
			END
	END

--delete record

IF @TransactionAction = 'Delete'
	BEGIN
	
		--set record status inactive = 0 (soft delete record)
		Update MASTER.ReportingHierarchyType 
		SET IsActive = 0, 
		UpdatedDT = @TransactionDT
		WHERE ReportingHierarchyTypeCode = @ReportingHierarchyTypeCode 

		--deactivate items
		--UPDATE [MASTER].[ReportingHierarchyItem]
		--SET IsActive = 0, 
		--UpdatedDT = @TransactionDT
		--WHERE ReportingHierarchyTypeID = @ReportingHierarchyTypeID

	END

IF @TransactionAction = 'UnDelete'
	BEGIN
	
		--set record status inactive = 0 (soft delete record)
		Update MASTER.ReportingHierarchyType 
		SET IsActive = 1, 
		UpdatedDT = @TransactionDT
		WHERE ReportingHierarchyTypeCode = @ReportingHierarchyTypeCode 

		--deactivate items
		--UPDATE [MASTER].[ReportingHierarchyItem]
		--SET IsActive = 1, 
		--UpdatedDT = @TransactionDT
		--WHERE ReportingHierarchyTypeID = @ReportingHierarchyTypeID

	END

--capture json data (get primary key value to store in audit table)

SET @PrimaryKeyID = (SELECT ReportingHierarchyTypeID FROM MASTER.ReportingHierarchyType WHERE ReportingHierarchyTypeCode = @ReportingHierarchyTypeCode)

SET @JSONData = (SELECT RHT.ReportingHierarchyTypeName,
						RHT.ReportingHierarchyTypeCode,
						RHT.ReportingHierarchyDescription,
						RHT.HierarchyLevelsLimit,
						RHT.IsUniqueBKMapping,
						RHT.CreatedDT,
						RHT.UpdatedDT,
						RHT.IsActive,
						DD.DataDomainCode AS [Data Domain Code]
FROM MASTER.ReportingHierarchyType RHT
LEFT JOIN 
[GOV].[DataDomain] DD
ON RHT.DataDomainID = DD.DataDomainID
WHERE ReportingHierarchyTypeCode = @ReportingHierarchyTypeCode
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )

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
