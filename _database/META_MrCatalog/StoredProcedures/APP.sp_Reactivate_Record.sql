SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      RJ Oosthuizen
-- Create Date: 4 March 2019
-- Description: Reactivates a record for any table (sets IsActive field from 0 to 1)
-- =============================================
CREATE PROCEDURE [APP].[sp_Reactivate_Record]
(
	@PrimaryKeyID INT = null, -- ID of the primary column
	@PrimaryBusinessColumnName VARCHAR(200) = null, -- primary column name
	@TableName VARCHAR(100), -- table name
	@TransactionPerson varchar(80), -- who actioned
    @MasterEntity varchar(50) -- from where actioned
)
AS
	/*
	-- Variable Workbench

	declare @PrimaryKeyID int = 125,
		@PrimaryBusinessColumnName varchar(200) = N'SortOrderValueID',
		@TableName varchar(100) = N'MASTER.SortOrderValue',
		@TransactionPerson varchar(80) = N'RJ',
		@MasterEntity varchar(50) = N'Sort Orders'
	--*/
	
	DECLARE @TransactionAction nvarchar(20) = 'UnDelete' -- type of transaction, "UnDelete"
    DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction
    DECLARE @JSONData varchar(max) = null -- to store in audit table
	
	--template script to reactivate a record
	DECLARE @Activate VARCHAR(MAX) = 
	'UPDATE ~TableNameReplace~
	SET IsActive = 1
	WHERE ~PrimaryColumnNameReplace~ = ~PrimaryKeyIDReplace~'

	--replace tablename, primary column name and primary ID number in to template script
	SET @Activate = REPLACE(@Activate, '~TableNameReplace~', @TableName)
	SET @Activate = REPLACE(@Activate, '~PrimaryColumnNameReplace~', @PrimaryBusinessColumnName)
	SET @Activate = REPLACE(@Activate, '~PrimaryKeyIDReplace~', @PrimaryKeyID)

	--execute new script
	EXEC(@Activate)

	--template script to audit a record
	--Declare @JSONQuery NVARCHAR(MAX) =
	--'SET @JSONDataFromQuery = (SELECT * 
 --    FROM ~TableNameReplace~ 
 --    WHERE ~PrimaryColumnNameReplace~ = ~PrimaryKeyIDReplace~
 --    FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER)'

	Declare @JSONQuery NVARCHAR(MAX) = (SELECT ReactivateQueryString 
										FROM APP.ReactivateQuery
										WHERE TableName = @TableName)
	
	--replace tablename, primary column name and primary ID number in to template script
	--SET @JSONQuery = REPLACE(@JSONQuery, '~TableNameReplace~', @TableName)
	--SET @JSONQuery = REPLACE(@JSONQuery, '~PrimaryColumnNameReplace~', @PrimaryBusinessColumnName)
	SET @JSONQuery = REPLACE(@JSONQuery, '~PrimaryKeyIDReplace~', @PrimaryKeyID)

	--execute template audit script and store result in @JSONData
	DECLARE @ParmDefinition nvarchar(500) -- declare param var
	SET @ParmDefinition = N'@JSONDataFromQuery varchar(max) OUTPUT' -- set param var to output to @JSONDataFromQuery within query
	EXEC sp_executesql @JSONQuery, @ParmDefinition, @JSONData OUTPUT -- execute script and store in @JSONData variable

    --call sp to store json audit data in table
    EXEC [APP].sp_Audit_Trail_Insert @TransactionPerson = @TransactionPerson, 
                                    @TransactionAction = @TransactionAction, 
                                    @MasterEntity = @MasterEntity, 
                                    @JSONData = @JSONData, 
                                    @TransactionDT = @TransactionDT, 
                                    @PrimaryKeyID = @PrimaryKeyID, 
                                    @TableName = @TableName




GO
