SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROC [APP].[sp_CRUD_Server]
  (
	@ServerID int,
	@ServerName varchar(100),
	@PublicIP varchar(100),
	@LocalIP varchar(100),
	@UserID int,
	@isActive bit,
	@AccessInstructions varchar(500),
	@TransactionPerson varchar(80),
    @TransactionAction nvarchar(20) = null,
	@ServerTypeID int,
	@MasterEntity varchar(50), -- from where actioned
	@ServerLocationID int
  )

  AS

BEGIN

DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate())  -- date of transaction

DECLARE @JSONData varchar(max) = null -- to store in audit table

DECLARE @PrimaryKeyID int = null -- primary key value for the table

DECLARE @TableName VARCHAR(50) = 'DC.Server' -- table name


SET @PublicIP = nullif(@PublicIP, 'NULL')
SET @AccessInstructions = nullif(@AccessInstructions, 'NULL')

IF @TransactionAction = 'Create'


BEGIN 
	INSERT INTO [DC].[Server] (ServerName,
							   LocalIP,
							   UserID,
							   AccessInstructions,
							   PublicIP,
							   CreatedDT,
							   isActive,
							   ServerTypeID,
							   ServerLocationID)
	VALUES (@ServerName,
			@LocalIP,
			@UserID,
			@AccessInstructions,
			@PublicIP,
			@TransactionDT,
			@isActive,
			@ServerTypeID,
			@ServerLocationID)

	SET @PrimaryKeyID = SCOPE_IDENTITY() --for auditing
END

--update record

IF @TransactionAction = 'Update'

BEGIN

UPDATE [DC].[Server]
SET
ServerName = @ServerName,
PublicIP = @PublicIP,
LocalIP = @LocalIP,
UserID = @UserID,
isActive =  @isActive,
AccessInstructions = @AccessInstructions,
ServerTypeID = @ServerTypeID,
UpdatedDT = @TransactionDT,
ServerLocationID = @ServerLocationID
WHERE ServerID = @ServerID

SET @PrimaryKeyID =  @ServerID --for auditing

END

IF @TransactionAction = 'Delete'

BEGIN

--set record status inactive = 0 (soft delete record)

Update [DC].[Server] 
SET IsActive = 0, 
UpdatedDT = @TransactionDT
WHERE ServerID = @ServerID

SET @PrimaryKeyID = @ServerID --for auditing

END

--capture json data (get primary key value to store in audit table)

--TODO: Check audit information required
SET @JSONData = (SELECT 
	S.ServerName,
	S.PublicIP,
	S.LocalIP,
	ST.ServerTypeDescription AS [Server Type],
	svrl.ServerLocationName AS [Server Location],
	s.CreatedDT,
	s.UpdatedDT,
	s.IsActive

FROM [DC].[Server] S
LEFT JOIN [DC].[ServerType] ST
ON S.ServerTypeID = ST.ServerTypeID 
LEFT JOIN [DC].ServerLocation svrl
ON S.ServerLocationID = svrl.ServerLocationID
WHERE ServerID = @PrimaryKeyID
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
