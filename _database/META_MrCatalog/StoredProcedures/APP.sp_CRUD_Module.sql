SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE PROCEDURE [APP].[sp_CRUD_Module](
@ModuleID int , --Primary key
@ModuleName varchar (80),
@ModuleDescription varchar (80),
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

DECLARE @TableName VARCHAR(50) = 'APP.Module' -- table name

--create record

IF @TransactionAction = 'Create'


BEGIN

--Insert new record
Insert Into APP.Module(ModuleName,ModuleDescription,CreatedDT,IsActive)
Values(@ModuleName,@ModuleDescription,@TransactionDT,1)
--remove fields not needed, keep CreatedDT and IsActive

SET @PrimaryKeyID = (SELECT ModuleID FROM  APP.Module WHERE ModuleName = @ModuleName)


END

--update record

IF @TransactionAction = 'Update'

BEGIN

--update existing record

UPDATE [APP].Module

--remove fields not needed, keep UpdatedDT
SET
UpdatedDT = @TransactionDT,
ModuleDescription = @ModuleDescription 
WHERE ModuleID = @ModuleID
SET @PrimaryKeyID = @ModuleID

END

--delete record

IF @TransactionAction = 'Delete'

BEGIN
Update [APP].Module
SET
IsActive = 0 Where ModuleID = @ModuleID
--set record status inactive = 0 (soft delete record)

SET @PrimaryKeyID = @ModuleID

END

--capture json data (get primary key value to store in audit table)


SET @JSONData = (SELECT *

FROM [APP].Module 

WHERE ModuleID = @PrimaryKeyID

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
