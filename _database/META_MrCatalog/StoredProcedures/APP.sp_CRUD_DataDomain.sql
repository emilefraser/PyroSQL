SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE PROCEDURE [APP].[sp_CRUD_DataDomain](
@DataDomainCode varchar (50), 
@DataDomainDescription varchar (200),
@DataDomainID int,--Primary key
@DataDomainParentID int,
@TransactionPerson varchar(80), -- who actioned
@MasterEntity varchar(50), -- from where actioned
@TransactionAction nvarchar(20) = null -- type of transaction, "Create", "Update", "Delete"

)

AS

BEGIN

DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate()) -- date of transaction

DECLARE @isActive bit -- indicate soft delete

DECLARE @JSONData varchar(max) = null -- to store in audit table

DECLARE @PrimaryKeyID int = null -- primary key value for the table

DECLARE @TableName VARCHAR(50) = 'GOV.DataDomain' -- table name

--create record

IF @TransactionAction = 'Create'


BEGIN

--Insert new record
Insert Into GOV.DataDomain(DataDomainCode
      ,DataDomainDescription
      ,DataDomainParentID
      ,CreatedDT
      ,IsActive)
Values(@DataDomainCode , @DataDomainDescription , @DataDomainParentID, @TransactionDT, 1)
--remove fields not needed, keep CreatedDT and IsActive

SET @PrimaryKeyID = SCOPE_IDENTITY()


END

--Insert new Parent ID
IF @TransactionAction = 'CreateParent'


BEGIN

--Insert new record
Insert Into GOV.DataDomain(DataDomainCode
      ,DataDomainDescription
      ,CreatedDT
      ,IsActive)
Values(@DataDomainCode,@DataDomainDescription,@TransactionDT,1)
--remove fields not needed, keep CreatedDT and IsActive

SET @PrimaryKeyID = @@IDENTITY


END


--update record

IF @TransactionAction = 'Update'

BEGIN

--update existing record

UPDATE [GOV].DataDomain

--remove fields not needed, keep UpdatedDT

Set
UpdatedDT = @TransactionDT,
DataDomainDescription = @DataDomainDescription
WHERE DataDomainID = @DataDomainID
SET @PrimaryKeyID = @DataDomainID
END

--delete record

IF @TransactionAction = 'Delete'

BEGIN
Update [GOV].DataDomain
SET
IsActive = 0,
UpdatedDT = @TransactionDT
Where DataDomainID = @DataDomainID
--set record status inactive = 0 (soft delete record)

SET @PrimaryKeyID = @DataDomainID

END



--capture json data (get primary key value to store in audit table)




SET @JSONData = (SELECT *

FROM [GOV].DataDomain 

WHERE DataDomainID = @PrimaryKeyID

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
