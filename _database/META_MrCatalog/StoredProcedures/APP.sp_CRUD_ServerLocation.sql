SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [APP].[sp_CRUD_ServerLocation](

--all table fields, remove the ones you dont need
@ServerLocationID int, --primary key of table
@ServerLocationCode varchar(80),
@ServerLocationName varchar(200),
@IsCloudLocation bit,
-- required params, please do not remove
@TransactionPerson varchar(80), -- who actioned
@MasterEntity varchar(50), -- from where actioned
@TransactionAction nvarchar(20) = null -- type of transaction, "Create", "Update", "Delete"
)

AS

BEGIN

DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate())  -- date of transaction

DECLARE @JSONData varchar(max) = null -- to store in audit table

DECLARE @PrimaryKeyID int = null -- primary key value for the table

DECLARE @TableName VARCHAR(50) = 'DC.[ServerLocation]' -- table name

--create record

IF @TransactionAction = 'Create'
	BEGIN
--Insert new record
--remove fields not needed, keep CreatedDT and IsActive
		INSERT INTO [DC].[ServerLocation] (ServerLocationCode,
							ServerLocationName,
							IsCloudLocation,
							CreatedDT,
							IsActive)
		VALUES(@ServerLocationCode,
							@ServerLocationName,
							@IsCloudLocation,
							@TransactionDT,
							1)

		SET @PrimaryKeyID = SCOPE_IDENTITY()  --for auditing
	END

--update record

IF @TransactionAction = 'Update'
	BEGIN
	--update existing record
		UPDATE [DC].[ServerLocation]
		SET 
		ServerLocationName = @ServerLocationName,
		IsCloudLocation = @IsCloudLocation,
		UpdatedDT = @TransactionDT
		WHERE ServerLocationID = @ServerLocationID
		
		SET @PrimaryKeyID = @ServerLocationID --for auditing
	END

--delete record

IF @TransactionAction = 'Delete'

BEGIN
	--set record status inactive = 0 (soft delete record)
	Update [DC].[ServerLocation]
	SET IsActive = 0, 
	UpdatedDT = @TransactionDT
	WHERE ServerLocationID = @ServerLocationID
	
	SET @PrimaryKeyID = @ServerLocationID --for auditing
END

--capture json data (get primary key value to store in audit table)

--correct audit data
SET @JSONData = (SELECT ServerLocationCode,
						ServerLocationName,
						IsCloudLocation,
						CreatedDT, 
						UpdatedDT, 
						IsActive
FROM [DC].[ServerLocation]
WHERE ServerLocationID = @PrimaryKeyID
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
