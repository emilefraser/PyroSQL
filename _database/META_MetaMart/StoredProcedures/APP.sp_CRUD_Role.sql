SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE PROCEDURE [APP].[sp_CRUD_Role](
@RoleID int , --Primary key
@RoleCode varchar (80),
@RoleDescription varchar(200),
@TransactionPerson varchar(80), -- who actioned
@MasterEntity varchar(50), -- from where actioned
@TransactionAction nvarchar(20) = null -- type of transaction, "Create", "Update", "Delete"

)

AS

BEGIN

DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction

DECLARE @isActive bit -- indicate soft delete

DECLARE @JSONData varchar(max) = null -- to store in audit table

DECLARE @PrimaryKeyID int = null -- primary key value for the table

DECLARE @TableName VARCHAR(50) = 'GOV.Role' -- table name

--create record

IF @TransactionAction = 'Create'


BEGIN

--Insert new record

--remove fields not needed, keep CreatedDT and IsActive
Insert into GOV.Role(RoleCode , RoleDescription , CreatedDT , IsActive)
Values(@RoleCode , @RoleDescription , @TransactionDT , 1)

SET @PrimaryKeyID = (SELECT RoleID FROM  GOV.Role WHERE RoleCode = @RoleCode)--Role code no duplicates


END

--update record

IF @TransactionAction = 'Update'

BEGIN

--update existing record

UPDATE [GOV].Role
SET 
RoleDescription = @RoleDescription,
UpdatedDT = @TransactionDT
where RoleID = @RoleID
--remove fields not needed, keep UpdatedDT
SET @PrimaryKeyID = @RoleID

END

--delete record

IF @TransactionAction = 'Delete'

BEGIN

--set record status inactive = 0 (soft delete record)
Update GOV.Role 
SET
IsActive = 0 Where RoleID = @RoleID
SET @PrimaryKeyID = @RoleID

END

--capture json data (get primary key value to store in audit table)


SET @JSONData = (SELECT *

FROM [GOV].Role 

WHERE RoleID = @PrimaryKeyID

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
