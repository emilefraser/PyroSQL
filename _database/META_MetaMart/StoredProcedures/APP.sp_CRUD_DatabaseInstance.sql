SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROC [APP].[sp_CRUD_DatabaseInstance]
  (
	@DatabaseInstanceName varchar(50),
	@ServerID int,
	@DatabaseAuthenticationTypeID int,
	@AuthUsername varchar(50),
	@AuthPassword varchar(50),
	@NetworkPort int,
	@isActive bit,
	@TransactionPerson varchar(80),
	@MasterEntity varchar(50),
    @TransactionAction nvarchar(20) = null,
	@DatabaseInstanceID int ,
	@IsDefaultInstance bit,
	@DatabaseTechnologyTypeID int,
	@ADFLinkedServiceID int
  )

  AS 
BEGIN 
DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate()) -- date of transaction
DECLARE @JSONData varchar(max) = null -- to store in audit table
DECLARE @PrimaryKeyID int = null -- primary key value for the table
DECLARE @TableName VARCHAR(50) = 'DC.DatabaseInstance' -- table name



SET @AuthUsername = nullif(@AuthUsername, 'NULL')
SET @AuthPassword = nullif(@AuthPassword, 'NULL')
SET @DatabaseInstanceName = nullif(@DatabaseInstanceName, 'NULL')
IF @ADFLinkedServiceID = -1
	BEGIN
		SET @ADFLinkedServiceID = NULL
	END

	IF @TransactionAction = 'Create'
	BEGIN 
		INSERT INTO [DC].[DatabaseInstance] (DatabaseInstanceName,
											ServerID,
											DatabaseAuthenticationTypeID
											,AuthUsername
											,AuthPassword
											,NetworkPort
											,IsActive
											,CreatedDT
											,IsDefaultInstance
											,DatabaseTechnologyTypeID
											,ADFLinkedServiceID)
		VALUES (@DatabaseInstanceName,
				@ServerID,
				@DatabaseAuthenticationTypeID,
				@AuthUsername,
				@AuthPassword,
				@NetworkPort,
				@isActive,
				@TransactionDT,
				@IsDefaultInstance,
				@DatabaseTechnologyTypeID,
				@ADFLinkedServiceID)

		SET @PrimaryKeyID = SCOPE_IDENTITY() --for auditing

	END

--update record

IF @TransactionAction = 'Update'

BEGIN

--update existing record
UPDATE [DC].[DatabaseInstance]
SET 
DatabaseInstanceName = @DatabaseInstanceName,
ServerID = @ServerID,
DatabaseAuthenticationTypeID = @DatabaseAuthenticationTypeID,
AuthUsername = @AuthUsername,
AuthPassword = @AuthPassword,
NetworkPort = @NetworkPort,
isActive = @isActive, --mark as active and inactive(replaces delete and reactivate)
IsDefaultInstance = @IsDefaultInstance,
UpdatedDT = @TransactionDT,
DatabaseTechnologyTypeID = @DatabaseTechnologyTypeID,
ADFLinkedServiceID = @ADFLinkedServiceID
WHERE DatabaseInstanceID = @DatabaseInstanceID

SET @PrimaryKeyID = @DatabaseInstanceID --for auditing

END

IF @TransactionAction = 'Delete'

BEGIN

--set record status inactive = 0 (soft delete record)

Update [DC].[DatabaseInstance]
SET IsActive = 0, 
UpdatedDT = @TransactionDT
WHERE DatabaseInstanceID = @DatabaseInstanceID
SET @PrimaryKeyID = @DatabaseInstanceID --for auditing

END


--capture json data (get primary key value to store in audit table)

--select correct audit data
SET @JSONData = (SELECT [Database Instance Name],
						[Server Name],
						[Database Authentication Type Name],
						[Auth Username],
						[Auth Password],
						[Is Default Instance],
						[Network Port],
						[Database Technology Type Name],
						[ADF Linked Service Name],
						[Created Date],
						[Updated Date],
						[Is Active]
						
FROM [DC].[vw_mat_DatabaseInstance]
WHERE [Database Instance ID] = @PrimaryKeyID
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES )

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
