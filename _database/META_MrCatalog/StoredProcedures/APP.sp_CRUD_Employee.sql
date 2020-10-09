SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [APP].[sp_CRUD_Employee](

--all table fields, remove the ones you dont need

@FirstName varchar(100),
@Surname varchar(100),
@Department varchar(100),
@ReportingHierarchyItemID int,
@EmployeeCode varchar(50),
-- required params, please do not remove

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

DECLARE @TableName VARCHAR(50) = 'SOURCELINK.Employee' -- table name

--create record

IF @TransactionAction = 'Create'

BEGIN

--check if record exists

IF EXISTS (SELECT 1 FROM SOURCELINK.Employee WHERE  @EmployeeCode = EmployeeCode)

BEGIN

SELECT 'Already Exist'

END

ELSE

BEGIN

--Insert new record

--remove fields not needed, keep CreatedDT and IsActive

INSERT INTO SOURCELINK.Employee (CreatedDT, EmployeeCode,FirstName,Surname,Department, IsActive,ReportingHierarchyItemID)

VALUES(@TransactionDT, @EmployeeCode,@FirstName,@Surname,@Department,1, @ReportingHierarchyItemID)

	SET @PrimaryKeyID = SCOPE_IDENTITY()  --for auditing
END

END

--update record

IF @TransactionAction = 'Update'

BEGIN

--check if record exists

IF EXISTS (SELECT 1 FROM SOURCELINK.Employee WHERE  @EmployeeCode = EmployeeCode)

BEGIN

--update existing record

UPDATE SOURCELINK.Employee 

--remove fields not needed, keep UpdatedDT

SET 
FirstName = @FirstName,
Surname = @Surname,
Department =  @Department,
ReportingHierarchyItemID = @ReportingHierarchyItemID,
UpdatedDT = @TransactionDT

WHERE EmployeeCode = @EmployeeCode

END

END

--delete record

IF @TransactionAction = 'Delete'

BEGIN

--set record status inactive = 0 (soft delete record)

Update SOURCELINK.Employee 

SET IsActive = 0, 

UpdatedDT = @TransactionDT

WHERE EmployeeCode = @EmployeeCode

END

--capture json data (get primary key value to store in audit table)

SET @PrimaryKeyID = (SELECT EmployeeID FROM SOURCELINK.Employee WHERE EmployeeCode = @EmployeeCode)

SET @JSONData = (SELECT *

FROM SOURCELINK.Employee 

WHERE EmployeeCode = @EmployeeCode

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
