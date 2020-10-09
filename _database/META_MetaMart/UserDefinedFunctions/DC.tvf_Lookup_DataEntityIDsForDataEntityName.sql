SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      RJ Oosthuizen
-- Create Date: 5 February 2019
-- Update Date: 16 February 2019
-- Description: Returns the Data Entity ID's for a Data Entity Name
-- Example: select * FROM DC.[tvf_Lookup_DataEntityIDsForDataEntityName]('SortOrderGrouping')
-- =============================================
CREATE FUNCTION [DC].[tvf_Lookup_DataEntityIDsForDataEntityName]
(
	--input paramater (table name)
	@DataEntityName VARCHAR(100)

)
RETURNS 
--temptable in which function returns results
@ResultsTable TABLE 
(
	--temp table columns to store results
	DataEntityID varchar(40),
	ServerName varchar(80),
	DatabaseInstance varchar(200),
	DatabaseName varchar(100),
	SchemaName varchar(80),
	TableName varchar(80)
)
AS
BEGIN
	--insert into temp table
	INSERT INTO @ResultsTable(DataEntityID, ServerName, DatabaseInstance, DatabaseName, SchemaName, TableName)
	SELECT d.[DataEntityID], ser.ServerName, dbi.DatabaseInstanceName, db.DatabaseName, s.[SchemaName], d.[DataEntityName] 
	--table name
	FROM DC.[DataEntity] d
	--schema
	INNER JOIN DC.[Schema] s
		ON s.SchemaID = d.SchemaID
	--database
	INNER JOIN DC.[Database] db
		ON db.DatabaseID = s.DatabaseID
	--instance
	INNER JOIN DC.[DatabaseInstance] dbi
		ON dbi.DatabaseInstanceID = db.DatabaseInstanceID
	--server
	INNER JOIN DC.[Server] ser
		ON ser.ServerID = dbi.ServerID
	--where table is equal to user table name
	WHERE @DataEntityName like DataEntityName

	RETURN
END

GO
