SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE PROCEDURE [APP].[sp_CRUD_Module_Action](

@ModuleActionID int, -- primary key
@ActionCode varchar(50),
@ActionDescription varchar(200),
@ModuleID int,
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

DECLARE @TableName VARCHAR(50) = 'APP.ModuleAction' -- table name

--create record

IF @TransactionAction = 'Create'


BEGIN

--Insert new record
Insert into APP.ModuleAction(ActionCode,ActionDescription,ModuleID,CreatedDT,IsActive)
Values(@ActionCode,@ActionDescription,@ModuleID,@TransactionDT,1)
--remove fields not needed, keep CreatedDT and IsActive

SET @PrimaryKeyID = SCOPE_IDENTITY()

END

--update record

IF @TransactionAction = 'Update'

BEGIN

--update existing record

UPDATE [APP].ModuleAction
SET
ActionDescription = @ActionDescription,
UpdatedDT = @TransactionDT
WHERE ModuleActionID = @ModuleActionID
--remove fields not needed, keep UpdatedDT
SET @PrimaryKeyID = @ModuleActionID


END

--delete record

IF @TransactionAction = 'Delete'

BEGIN


--set record status inactive = 0 (soft delete record)
Update APP.ModuleAction
Set
IsActive = 0 
where ModuleActionID = @ModuleActionID
SET @PrimaryKeyID = @ModuleActionID

END

--capture json data (get primary key value to store in audit table)


SET @JSONData = (SELECT *

FROM [APP].ModuleAction 

WHERE ModuleActionID = @PrimaryKeyID

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
