SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      <Matthew Falcao Pereira>
-- Create Date: <2019/10/29>
-- Description: <Generic Stored Proc for linking items to DataDomain>
-- =============================================
CREATE PROCEDURE [APP].[sp_Link_DataDomain_And_Item]
(
    -- Add the parameters for the stored procedure here
    @has_linking_table bit, --determines if DDID needs to be linked directly to table or linking table
	@DataDomainIDString varchar(max), -- DataDomain ID String
	@MasterEntity varchar(max), -- The Main table from where the link will be made 
	@LinkingTableName varchar(max), -- The table that is linking with the Master Entity - Main Table 
	--@LinkingTableItemColumnName varchar(max), -- the column that should become linked
	@ItemID int , -- The item you want to link 
	@ItemPrimaryKeyColumnName varchar(max) -- Primary column of the table where Item is in

)
AS
BEGIN
--declare staging tables where the values will be stored temporarily 

--test bench
--declare @DataDomainIDString varchar(max) = '3, 4, 5'
--declare @ItemID int = 10
--declare @has_linking_table bit = 1
--declare @MasterEntity varchar(max) = 'APP.testgenericlinkfunction'
--declare @ItemPrimaryKeyColumnName varchar(max) = 'testgenericlinkfunctionID'
--declare @LinkingTableName varchar(max) = '[APP].[TestGenericLinkingFunctionLinkingTable]'
--test bench end

DECLARE @ExecutionQuery varchar(max)


IF @has_linking_table = 0
	BEGIN
		--declare query to execute for non linking table assignments
		SET @ExecutionQuery =
		'
		DECLARE @TransactionDT DateTime2(7) = Getdate()
		DECLARE @PairDataDomainIDtoItemID TABLE
		(
			ItemID int ,
			DataDomainID int
		)
		  
		
		INSERT INTO @PairDataDomainIDtoItemID(DataDomainID,ItemID)
		SELECT Value , ~!ItemID!~
		FROM DC.tvf_Split_StringWithDelimiter(''~!DataDomainIDString!~'' , '','')
		
		DELETE FROM @PairDataDomainIDtoItemID 
		WHERE DataDomainID = 0
		
		
		UPDATE  ~!MasterEntity!~
		SET  DataDomainID = (SELECT DataDomainID FROM @PairDataDomainIDtoItemID),
		UpdatedDT = @TransactionDT
		WHERE ~!ItemPrimaryKeyColumnName!~ = ~!ItemID!~
		'
		
		 
		--replace MasterEntity , ItemPrimaryKeyColumnName and ItemID
		SET @ExecutionQuery = Replace(@ExecutionQuery,'~!MasterEntity!~',@MasterEntity) --replace table name
		SET @ExecutionQuery = Replace(@ExecutionQuery,'~!ItemPrimaryKeyColumnName!~',@ItemPrimaryKeyColumnName) --replace table primary key column name
		SET @ExecutionQuery = Replace(@ExecutionQuery,'~!ItemID!~',@ItemID) --replace primary key id
		SET @ExecutionQuery = Replace(@ExecutionQuery,'~!DataDomainIDString!~',@DataDomainIDString) --replace datadomainid string(should be one value)
		
		--Execute stored proc
		EXEC(@ExecutionQuery)
		
	END


 IF @has_linking_table = 1
	BEGIN
		SET @ExecutionQuery =
		'
		DECLARE @TransactionDT DateTime2(7) = GetDate()
		DECLARE @PairDataDomainIDtoItemID TABLE
		(
			ItemID int ,
			DataDomainID int
		)
		  
		
		INSERT INTO @PairDataDomainIDtoItemID(DataDomainID,ItemID)
		SELECT Value , ~!ItemID!~
		FROM DC.tvf_Split_StringWithDelimiter(''~!DataDomainIDString!~'' , '','')
		
		DELETE FROM @PairDataDomainIDtoItemID 
		WHERE DataDomainID = 0
		
		

		UPDATE ~!LinkingTableName!~
		SET IsActive = 0
		WHERE ~!ItemPrimaryKeyColumnName!~ = ~!ItemID!~ --set all IsActive for current item to 0


		UPDATE ~!LinkingTableName!~
		SET IsActive = 1
		FROM ~!LinkingTableName!~ gen
		WHERE EXISTS (SELECT * FROM @PairDataDomainIDtoItemID  tmp
							WHERE tmp.DataDomainID = gen.DataDomainID
							AND tmp.ItemID = gen.~!ItemPrimaryKeyColumnName!~
							AND gen.IsActive = 0) --update existing IsActive of datadomains to 1



		INSERT INTO ~!LinkingTableName!~(DataDomainID, ~!ItemPrimaryKeyColumnName!~, CreatedDT, IsActive)
		SELECT tmp.DataDomainID, tmp.ItemID, @TransactionDT, 1 
		FROM @PairDataDomainIDtoItemID tmp
		WHERE NOT EXISTS (SELECT * FROM ~!LinkingTableName!~ gen
							WHERE tmp.DataDomainID = gen.DataDomainID
							AND tmp.ItemID = gen.~!ItemPrimaryKeyColumnName!~
							AND gen.IsActive = 1) --insert new datadomains to link
		'

		SET @ExecutionQuery = Replace(@ExecutionQuery,'~!ItemID!~',@ItemID) --replace primary key id
		SET @ExecutionQuery = Replace(@ExecutionQuery,'~!DataDomainIDString!~',@DataDomainIDString) --replace datadomainid string(can be multiple values)
		SET @ExecutionQuery = Replace(@ExecutionQuery,'~!LinkingTableName!~',@LinkingTableName) --replace linking table name
		SET @ExecutionQuery = Replace(@ExecutionQuery,'~!ItemPrimaryKeyColumnName!~',@ItemPrimaryKeyColumnName) --replace table primary key column name

		EXEC (@ExecutionQuery)

	END
 END

GO
