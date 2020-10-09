SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
 CREATE PROC [APP].[sp_CRUD_DataEntity]
  (
	@FriendlyName varchar(100),
	@Description varchar(100),
	@TransactionPerson varchar(80),
	@MasterEntity varchar(50), -- from where actioned
    @TransactionAction nvarchar(20) = null,
	@DataEntityID int
  )
AS

BEGIN

DECLARE @TransactionDT datetime2(7) = [MASTER].[udf_Convert_Date_To_UTC](getDate()) -- date of transaction

DECLARE @JSONData varchar(max) = null -- to store in audit table

DECLARE @PrimaryKeyID int = null -- primary key value for the table

DECLARE @TableName VARCHAR(50) = 'DC.DataEntity' -- table name

--create record

--IF @TransactionAction = 'Create'


--BEGIN

----not needed for Powerapps as we do not create new DE's
----Will add when needed
--END

SET @FriendlyName = nullif(@FriendlyName, 'NULL')
SET @Description = nullif(@Description, 'NULL')


IF @TransactionAction = 'Update'

	BEGIN 
		Update [DC].[DataEntity]
		SET FriendlyName = @FriendlyName,
		    [Description] = @Description,
			UpdatedDT = @TransactionDT

		WHERE DataEntityID = @DataEntityID

END


----not needed for Powerapps as we do not create new DE's
--delete record

--IF @TransactionAction = 'Delete'

--BEGIN

----set record status inactive = 0 (soft delete record)

--Update [DC].[DataEntity]

--SET IsActive = 0, 

--UpdatedDT = @TransactionDT

--WHERE DataEntityID = @DataEntityID


--END

--capture json data (get primary key value to store in audit table)

--uncomment when audit needed, remember to obtain primary key
--SET @JSONData = (SELECT *

--FROM [DC].[DataEntity]

--WHERE DataEntityID = @PrimaryKeyID

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
