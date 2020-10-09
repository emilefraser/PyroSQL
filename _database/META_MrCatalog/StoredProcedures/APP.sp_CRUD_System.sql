SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [APP].[sp_CRUD_System](

--all table fields, remove the ones you dont need
@SystemName varchar(100),
@SystemAbbreviation varchar(10),
@Description varchar(200),
@AccessInstructions varchar(500), 
@UserID int,
@IsBusinessApplication bit,
@IsActive bit,
@DataDomainID int,
@SystemID int,
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

DECLARE @TableName VARCHAR(50) = 'DC.System' -- table name


SET @DataDomainID = nullif(@DataDomainID, 0)

--create record

IF @TransactionAction = 'Create'


BEGIN

--Insert new record

--remove fields not needed, keep CreatedDT and IsActive

INSERT INTO [DC].[System] (
						   SystemName,
						   SystemAbbreviation, 
						   [Description],  
						   AccessInstructions,
						   UserID,
						   IsBusinessApplication,
						   IsActive,
						   DataDomainID,
						   CreatedDT)
VALUES (
		@SystemName, 
		@SystemAbbreviation, 
		@Description,  
		@AccessInstructions,
		@UserID,
		@IsBusinessApplication,
		@IsActive,
		@DataDomainID,
		@TransactionDT)

SET @PrimaryKeyID = SCOPE_IDENTITY()  --for auditing
END

--update record

IF @TransactionAction = 'Update'

BEGIN

--update existing record

UPDATE [DC].[System]
SET 
SystemName = @SystemName,
SystemAbbreviation = @SystemAbbreviation,
[Description] = @Description,
AccessInstructions = @AccessInstructions,
UserID = @UserID,
IsBusinessApplication = @IsBusinessApplication,
IsActive = @IsActive,
DataDomainID = @DataDomainID,
UpdatedDT = @TransactionDT
WHERE SystemID = @SystemID

SET @PrimaryKeyID = @SystemID --for auditing

END

--delete record

IF @TransactionAction = 'Delete'

BEGIN

--set record status inactive = 0 (soft delete record)

Update [DC].[System]
SET IsActive = 0, 
UpdatedDT = @TransactionDT
WHERE SystemID = @SystemID

SET @PrimaryKeyID = @SystemID --for auditing

END

--capture json data (get primary key value to store in audit table)

--correct audit data
SET @JSONData = (SELECT SystemName,
						SystemAbbreviation,
						[Description],
						AccessInstructions,
						CreatedDT,
						UpdatedDT,
						IsActive
FROM DC.[System]
WHERE SystemID = @PrimaryKeyID
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
