SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [APP].[sp_CRUD_ADF_Linked_Service](
@ADFLinkedServiceID int , --Primary key
@ADFLinkedServiceCode varchar (40),
@ADFLinkedServiceName varchar (100),
@IntegrationRuntimeID int,
@DatabaseTechnologyTypeID int,
@TransactionPerson varchar(80), -- who actioned
@MasterEntity varchar(50), -- from where actioned
@TransactionAction nvarchar(20) = null -- type of transaction, "Create", "Update", "Delete"

)

AS

BEGIN

DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate()) -- date of transaction
DECLARE @JSONData varchar(max) = null -- to store in audit table

DECLARE @PrimaryKeyID int = null -- primary key value for the table

DECLARE @TableName VARCHAR(50) = 'DC.ADFLinkedService' -- table name

--create record

IF @TransactionAction = 'Create'
	BEGIN
		--Insert new record
		INSERT INTO DC.ADFLinkedService(
							ADFLinkedServiceCode,
							ADFLinkedServiceName,
							IntegrationRuntimeID,
							DatabaseTechnologyTypeID,
							CreatedDT,
							IsActive
						)
		VALUES(
			@ADFLinkedServiceCode,
			@ADFLinkedServiceName,
			@IntegrationRuntimeID,
			@DatabaseTechnologyTypeID,
			@TransactionDT,
			1
		)
		
		SET @PrimaryKeyID = SCOPE_IDENTITY() 
	END

--update record
IF @TransactionAction = 'Update'
	BEGIN
		--update existing record
		UPDATE DC.ADFLinkedService
		SET
		ADFLinkedServiceName = @ADFLinkedServiceName,
		IntegrationRuntimeID = @IntegrationRuntimeID,
		DatabaseTechnologyTypeID = @DatabaseTechnologyTypeID,
		UpdatedDT = @TransactionDT
		WHERE ADFLinkedServiceID = @ADFLinkedServiceID

		SET @PrimaryKeyID = @ADFLinkedServiceID
	END

--delete record
IF @TransactionAction = 'Delete'
	BEGIN
		UPDATE DC.ADFLinkedService
		SET
		IsActive = 0 
		WHERE ADFLinkedServiceID= @ADFLinkedServiceID
		--set record status inactive = 0 (soft delete record)
		
		SET @PrimaryKeyID = @ADFLinkedServiceID
	END

--capture json data (get primary key value to store in audit table)


SET @JSONData = (SELECT *
FROM DC.vw_mat_ADFLinkedService
WHERE [ADF Linked Service ID]= @PrimaryKeyID
FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES)

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
