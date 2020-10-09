SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
 CREATE PROC [APP].[sp_CRUD_Field]
  (
	@FriendlyName varchar(100),
	@Description varchar(1000),
	@TransactionPerson varchar(80),
    @TransactionAction nvarchar(20) = null,
	@MasterEntity varchar(50),
	@FieldID int 
  )
  As
	BEGIN 
DECLARE @JSONData varchar(max) = null -- to store in audit table

DECLARE @PrimaryKeyID int = null -- primary key value for the table

DECLARE @TableName VARCHAR(50) = 'DC.Field' -- table name

DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate())  -- date of transaction 

--IF @TransactionAction = 'Create'


--BEGIN

----will add when needed in PowerApps
--END

SET @FriendlyName = nullif(@FriendlyName, 'NULL')
SET @Description = nullif(@Description, 'NULL')

IF @TransactionAction = 'Update'

	BEGIN 
		Update [DC].[Field]
		SET FriendlyName= @FriendlyName,
		    [Description] = @Description,
			UpdatedDT = @TransactionDT
		WHERE FieldID = @FieldID

	END

	--delete record
--will add when needed
--IF @TransactionAction = 'Delete'

--BEGIN

----set record status inactive = 0 (soft delete record)

--Update [DC].[Field] 

--SET IsActive = 0, 

--UpdatedDT = @TransactionDT

--WHERE FieldID = @FieldID

--SET @PrimaryKeyID = @FieldID

--END

--will add when needed
--SET @JSONData = (SELECT *

--FROM [DC].[Field]

--WHERE FieldID = @PrimaryKeyID

--FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER )

----call sp to store json audit data in table

--EXEC [APP].sp_Audit_Trail_Insert @TransactionPerson = @TransactionPerson,

--@TransactionAction = @TransactionAction,

--@MasterEntity = @MasterEntity,

--@JSONData = @JSONData,

--@TransactionDT = @TransactionDT,

--@PrimaryKeyID = @PrimaryKeyID,

--@TableName = @TableName

END

GO
