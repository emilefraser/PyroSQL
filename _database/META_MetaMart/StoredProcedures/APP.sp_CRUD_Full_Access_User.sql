SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [APP].[sp_CRUD_Full_Access_User](

--all table fields, remove the ones you dont need

@FullAccessUserID int, -- primary key
@DomainAccountOrGroup varchar(200),
@IsFullAccessUser bit,
@IsDeveloper bit,

-- required params, please do not remove

@TransactionPerson varchar(80), -- who actioned

@MasterEntity varchar(50), -- from where actioned

@TransactionAction nvarchar(20) = null -- type of transaction, "Create", "Update", "Delete"

)

AS

BEGIN

DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction

DECLARE @JSONData varchar(max) = null -- to store in audit table

DECLARE @PrimaryKeyID int = null -- primary key value for the table

DECLARE @TableName VARCHAR(50) = 'ACCESS.FullAccessUser' -- table name

--create record

IF @TransactionAction = 'Create'


BEGIN

--Insert new record

--remove fields not needed, keep CreatedDT and IsActive

INSERT INTO [ACCESS].FullAccessUser (DomainAccountOrGroup, IsFullAccessUser, IsDeveloper, CreatedDT,  IsActive)

VALUES( @DomainAccountOrGroup, @IsFullAccessUser, @IsDeveloper, @TransactionDT,  1)

SET @PrimaryKeyID = (SELECT FullAccessUserID FROM  ACCESS.FullAccessUser WHERE DomainAccountOrGroup = @DomainAccountOrGroup AND IsFullAccessUser = @IsFullAccessUser AND IsDeveloper = @IsDeveloper)


END

--update record

IF @TransactionAction = 'Update'

BEGIN

--update existing record

UPDATE [ACCESS].FullAccessUser

--remove fields not needed, keep UpdatedDT

SET 
DomainAccountOrGroup = @DomainAccountOrGroup,
IsFullAccessUser = @IsFullAccessUser,
IsDeveloper = @IsDeveloper,

UpdatedDT = @TransactionDT

WHERE FullAccessUserID = @FullAccessUserID

SET @PrimaryKeyID = @FullAccessUserID

END

--delete record

IF @TransactionAction = 'Delete'

BEGIN

--set record status inactive = 0 (soft delete record)

Update [ACCESS].FullAccessUser 

SET IsActive = 0, 

UpdatedDT = @TransactionDT

WHERE FullAccessUserID = @FullAccessUserID

SET @PrimaryKeyID = @FullAccessUserID

END

--capture json data (get primary key value to store in audit table)


SET @JSONData = (SELECT *

FROM [ACCESS].FullAccessUser 

WHERE FullAccessUserID = @PrimaryKeyID

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
