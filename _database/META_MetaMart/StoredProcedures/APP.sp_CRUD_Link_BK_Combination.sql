SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [APP].[sp_CRUD_Link_BK_Combination](

--all table fields, remove the ones you dont need
@LinkBKCombinationID int, -- primary key
@BusinessKeysIDString varchar(max), --datavalue of BK
@ReportingHierarchyItemID int, -- primary key for reporting hierarchy item table

@TransactionPerson varchar(80), -- who actioned
@MasterEntity varchar(50), -- from where actioned
@TransactionAction nvarchar(20) = null -- type of transaction, Create"", "Delete"
)

AS

BEGIN

----Testing purpose 
--DECLARE @TransactionAction nvarchar(20) = null
--Declare @BusinessKeysIDString varchar(max) = 'BK test 1,BK test 2,BK test,BK test 8'
--Declare @ReportingHierarchyItemID int = 1853

--get link id for item id
DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction
DECLARE @JSONData varchar(max) = null -- to store in audit table
DECLARE @PrimaryKeyID int = null -- primary key value for the table
DECLARE @TableName VARCHAR(50) = 'MASTER.LinkBKCombination' -- table name
DECLARE @LinkID INT = (SELECT TOP 1 LinkID 
						FROM [MASTER].[LinkReportingHierarchyItemToBKCombination]
						WHERE ReportingHierarchyItemID = @ReportingHierarchyItemID)



--Declare temp table for the selected BK's from powerapps
DECLARE @BusinessKeyTemp Table
(
	LinkID int,
	DataCatalogFieldID int,
	BusinessKey varchar(50)
)
--insert into temp table the selected id's
INSERT INTO @BusinessKeyTemp(BusinessKey, DataCatalogFieldID, LinkID)
SELECT value, 
(SELECT FieldID 
FROM [INTEGRATION].[ingress_DistinctBKMapping] 
WHERE DataValue = value),
@LinkID
FROM DC.tvf_Split_StringWithDelimiter(@BusinessKeysIDString, ',')

--SELECT * FROM @BusinessKeyTemp

--Delete BK = NULL created by split function
Delete FROM @BusinessKeyTemp
Where DataCatalogFieldID is NULL

--SELECT * FROM @BusinessKeyTemp


if @TransactionAction = 'Assign'
BEGIN

--New Reporting Business Keys
--Declare temp table to for the selected Business Keys that do notr exist in the table yet
DECLARE @NewBusinessKeysToLink Table
 ( 
   DataCatalogFieldID int,
   LinkID int,
   BusinessKey varchar(50)
 )

 --Populate @NewBusinessKeysToLink with the new Business Keys to be added to the table
 Insert Into @NewBusinessKeysToLink(DataCatalogFieldID,LinkID,BusinessKey)
 Select BKT.DataCatalogFieldID, BKT.LinkID, BKT.BusinessKey
 FROM @BusinessKeyTemp BKT
 WHERE NOT EXISTS (SELECT * FROM [MASTER].[LinkBKCombination] LRC
					WHERE
						BKT.DataCatalogFieldID = LRC.DataCatalogFieldID
						and BKT.BusinessKey = LRC.BusinessKey
						and BKT.LinkID = LRC.LinkID
					)

   --testing
   --SELECT * FROM @NewBusinessKeysToLink
   
   --SET IDENTITY_INSERT [MASTER].[LinkBKCombination] ON
   INSERT INTO [MASTER].[LinkBKCombination]
   (LinkID,BusinessKey,DataCatalogFieldID,CreatedDT,IsActive)
   SELECT LinkID,BusinessKey,DataCatalogFieldID,@TransactionDT,1
   FROM @NewBusinessKeysToLink


   DECLARE @UpdateBusinessKeysToLink Table 
   (
    LinkBKCombinationID int,
	LinkID int,
	DataCatalogFieldID int,
	BusinessKey varchar(50),
	UpdatedDT  datetime2(7),
	IsActive bit
   )

   INSERT INTO @UpdateBusinessKeysToLink
   (LinkBKCombinationID,LinkID,DataCatalogFieldID,BusinessKey,UpdatedDT,IsActive)
   SELECT LBK.LinkBKCombinationID,LBK.LinkID,LBK.DataCatalogFieldID,LBK.BusinessKey,@TransactionDT,1 
   FROM [MASTER].[LinkBKCombination] LBK
   WHERE EXISTS(SELECT * FROM @BusinessKeyTemp BK
   WHERE BK.LinkID = LBK.LinkID
   AND Bk.BusinessKey = LBK.BusinessKey)
   AND LBK.IsActive = 0

   --testing
  -- select * from @UpdateBusinessKeysToLink

   UPDATE [MASTER].[LinkBKCombination] 
   SET IsActive = 1,
   UpdatedDT = @TransactionDT 
   FROM @UpdateBusinessKeysToLink UBK
   LEFT JOIN [MASTER].[LinkBKCombination]  LBK
   on
   UBK.LinkBKCombinationID = LBK.LinkBKCombinationID


   END

IF @TransactionAction = 'UnAssign'
BEGIN

DECLARE @BusinessKeysToUnAssign Table
(
	LinkBKCombinationID int,
	LinkID int,
	DataCatalogFieldID int,
	BusinessKey varchar(50),
	UpdatedDT  datetime2(7),
	IsActive bit
)

INSERT INTO @BusinessKeysToUnAssign 
  (LinkBKCombinationID, LinkID, DataCatalogFieldID, BusinessKey, UpdatedDT, IsActive)
   SELECT LBK.LinkBKCombinationID,LBK.LinkID,LBK.DataCatalogFieldID,LBK.BusinessKey,@TransactionDT,1
   FROM [MASTER].[LinkBKCombination] LBK
   WHERE EXISTS(SELECT * FROM @BusinessKeyTemp BK
   WHERE  BK.LinkID = LBK.LinkID
   AND BK.BusinessKey = LBK.BusinessKey
   AND BK.DataCatalogFieldID = LBK.DataCatalogFieldID)
   AND LBK.IsActive = 1

   --testing
   --SELECT * FROM @BusinessKeysToUnAssign

UPDATE [MASTER].[LinkBKCombination] 
   SET IsActive = 0,
   UpdatedDT = @TransactionDT 
   FROM @BusinessKeysToUnAssign UBK
   LEFT JOIN [MASTER].[LinkBKCombination]  LBK
   on
   UBK.LinkBKCombinationID = LBK.LinkBKCombinationID
   AND UBK.LinkID = LBK.LinkID
   AND UBK.DataCatalogFieldID = LBK.DataCatalogFieldID
   AND UBK.BusinessKey = LBK.BusinessKey

END

--capture json data (get primary key value to store in audit table)

--TODO: Check audit information required
--SET @JSONData = 
--			(
--		SELECT 
--		[BusinessKey],
--		[CreatedDT],
--		[IsActive]
--		FROM
--		[MASTER].[LinkBKCombination]
--		FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER )

--		--call sp to store json audit data in table

--EXEC [APP].sp_Audit_Trail_Insert @TransactionPerson = @TransactionPerson,
--@TransactionAction = @TransactionAction,
--@MasterEntity = @MasterEntity,
--@JSONData = @JSONData,
--@TransactionDT = @TransactionDT,
--@PrimaryKeyID = @PrimaryKeyID,
--@TableName = @TableName
END

















--DECLARE @isActive bit -- indicate soft delete

--DECLARE @JSONData varchar(max) = null -- to store in audit table

--DECLARE @PrimaryKeyID int = null -- primary key value for the table

--DECLARE @TableName VARCHAR(50) = 'MASTER.LinkBKCombination' -- table name

--DECLARE @LinkID int


--test for link
--IF (not exists(SELECT ReportingHierarchyItemID FROM MASTER.LinkReportingHierarchyItemToBKCombination WHERE ReportingHierarchyItemID = @ReportingHierarchyItemID))
--	BEGIN
--		--insert link record
--		INSERT INTO MASTER.LinkReportingHierarchyItemToBKCombination (ReportingHierarchyItemID, CreatedDT, IsActive)
--		VALUES (@ReportingHierarchyItemID, @TransactionDT, 1)

--		SET @LinkID = @@IDENTITY -- get link id to insert into LinkBKCombination
--	END
--ELSE
--	BEGIN
--	--get linkid of existing link
--		SET @LinkID = (SELECT LinkID FROM MASTER.LinkReportingHierarchyItemtoBKCombination WHERE ReportingHierarchyItemID = @ReportingHierarchyItemID)
--	END



--create record
--IF @TransactionAction = 'Create'
--	BEGIN
--	--check if record exists
--	IF EXISTS (SELECT 1 FROM MASTER.LinkBKCombination WHERE  @LinkID = LinkID AND @BusinessKey = BusinessKey AND @DataCatalogFieldID = DataCatalogFieldID)
--		BEGIN
--			SELECT 'Already Exist'
--			RETURN -- exit stored procedure
--		END
--	ELSE
--		BEGIN
--		If(@LinkBKCombinationID = 0)
--			--Insert new record
--			--remove fields not needed, keep CreatedDT and IsActive
--			INSERT INTO MASTER.LinkBKCombination (BusinessKey, DataCatalogFieldID, LinkID,  IsActive, CreatedDT)
--			VALUES(@BusinessKey, @DataCatalogFieldID, @LinkID,  1, @TransactionDT)

--			SET @PrimaryKeyID = @@IDENTITY -- primary key for auditing
--		END
--	END

	--update record

--IF @TransactionAction = 'Update'
--	BEGIN
--		--check if record exists
--		IF EXISTS (SELECT 1 FROM MASTER.LinkBKCombination WHERE  @LinkID = LinkID AND @BusinessKey = BusinessKey AND @DataCatalogFieldID = DataCatalogFieldID)
--			BEGIN
--				--update existing record
--				UPDATE MASTER.LinkBKCombination 
--				--remove fields not needed, keep UpdatedDT
--				SET 
--				IsActive = 1, 
--				UpdatedDT = @TransactionDT
--				WHERE LinkBKCombinationID = @LinkBKCombinationID
--			END
--	END

--delete record
--IF @TransactionAction = 'Delete'
--	BEGIN
--		--set record status inactive = 0 (soft delete record)
--		Update MASTER.LinkBKCombination 
--		SET IsActive = 0, 
--		UpdatedDT = @TransactionDT
--		WHERE LinkBKCombinationID = @LinkBKCombinationID

--		SET @PrimaryKeyID = (SELECT LinkBKCombinationID FROM MASTER.LinkBKCombination WHERE LinkBKCombinationID = @LinkBKCombinationID)
--	END

--capture json data (get primary key value to store in audit table)
--SET @JSONData = (SELECT *
--FROM MASTER.LinkBKCombination 
--WHERE LinkBKCombinationID = @PrimaryKeyID
--FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER )

----call sp to store json audit data in table
--EXEC [APP].sp_Audit_Trail_Insert @TransactionPerson = @TransactionPerson,
--@TransactionAction = @TransactionAction,
--@MasterEntity = @MasterEntity,
--@JSONData = @JSONData,
--@TransactionDT = @TransactionDT,
--@PrimaryKeyID = @PrimaryKeyID,
--@TableName = @TableName
--END


GO
