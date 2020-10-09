SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

 --Author:      Emile Fraser
 --Create Date: 6 June 2019
 --Description: Generate a Field list for a select statement from the ODS area table with a standard alias prefix


--SELECT [DMOD].[udf_get_FieldList_WithAlias_ODS](10399)
CREATE FUNCTION [DMOD].[xx_udf_get_FieldList_WithAlias_ODS_DONTDELETE2]
(
    @ODS_DataEntityID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	--DECLARE @ODS_DataEntityID INT = 10399

	DECLARE @MatchingTable TABLE 
	(
		RowType VARCHAR(20) 
	,	DataEntityID INT, DataEntityName VARCHAR(250), SchemaID INT, SchemaName VARCHAR(250)
	,	DatabaseID INT,DatabaseName VARCHAR(250), DatabaseInstanceID INT,DatabaseInstanceName VARCHAR(250)
	,	ServerID INT,ServerName VARCHAR(250), SystemID INT, SystemName VARCHAR(250),SystemAbbreviation VARCHAR(250)
	)

	INSERT INTO @MatchingTable
	(
		  RowType
		, DataEntityID, DataEntityName
		, SchemaID, SchemaName
		, DatabaseID, DatabaseName
		, DatabaseInstanceID, DatabaseInstanceName
		, ServerID, ServerName
		, SystemID, SystemName, SystemAbbreviation
	)
	SELECT 
		'ODS' AS RowType
		,	de.DataEntityID AS ODS_ODS_DataEntityID
		,	de.DataEntityName AS ODS_
		,	s.SchemaID AS ODS_SchemaID
		,	s.SchemaName AS ODS_SchemaName
		,	d.DatabaseID AS ODS_DatabaseID
		,	d.DatabaseName AS ODS_DatabaseName
		,	di.DatabaseInstanceID AS ODS_DatabaseInstanceID
		,	di.DatabaseInstanceName AS ODS_DatabaseInstanceName
		,	se.ServerID AS ODS_ServerID
		,	se.ServerName AS ODS_Serverame
		,	sy.SystemID AS ODS_SystemID
		,	sy.SystemName AS ODS_SystemName
		,	sy.SystemAbbreviation AS ODS_SystemAbbreviation
		FROM DC.DataEntity AS de 
		INNER JOIN DC.[Schema] AS s ON de.SchemaID = s.SchemaID
		INNER JOIN DC.[Database] AS d ON d.DatabaseID = s.DatabaseID
		INNER JOIN DC.[DatabaseInstance] AS di ON di.DatabaseInstanceID = d.DatabaseInstanceID
		INNER JOIN DC.[Server] AS se ON se.ServerID = di.ServerID
		INNER JOIN DC.[System] AS sy ON sy.SystemID = COALESCE(d.SystemID, s.SystemID)
		WHERE de.DataEntityID = @ODS_DataEntityID

		DECLARE @Source_DataEntityID INT = (SELECT([DC].[udf_get_SourceSystem_DataEntityID] (@ODS_DataEntityID)))
		DECLARE @Source_SystemID INT =  (SELECT([DC].[udf_GetSourceSystemIDForDataEntityID] ((SELECT [DC].[udf_get_SourceSystem_DataEntityID] (@ODS_DataEntityID)))))
		DECLARE @Source_SchemaID INT =  (SELECT([DC].[udf_GetSchemaIDForDataEntityID]((SELECT [DC].[udf_get_SourceSystem_DataEntityID] (@ODS_DataEntityID)))))

		-- INSERT Comparable Source Row corresponding to ODS 
		INSERT INTO @MatchingTable
		(
			  RowType
			, DataEntityID, DataEntityName
			, SchemaID, SchemaName
			, DatabaseID, DatabaseName
			, DatabaseInstanceID, DatabaseInstanceName
			, ServerID, ServerName
			, SystemID, SystemName, SystemAbbreviation
		)
		SELECT 
			'Source' AS RowType
		,	de.DataEntityID AS ODS_ODS_DataEntityID
		,	de.DataEntityName AS ODS_
		,	s.SchemaID AS ODS_SchemaID
		,	s.SchemaName AS ODS_SchemaName
		,	d.DatabaseID AS ODS_DatabaseID
		,	d.DatabaseName AS ODS_DatabaseName
		,	di.DatabaseInstanceID AS ODS_DatabaseInstanceID
		,	di.DatabaseInstanceName AS ODS_DatabaseInstanceName
		,	se.ServerID AS ODS_ServerID
		,	se.ServerName AS ODS_Serverame
		,	sy.SystemID AS ODS_SystemID
		,	sy.SystemName AS ODS_SystemName
		,	sy.SystemAbbreviation AS ODS_SystemAbbreviation
		FROM DC.DataEntity AS de 
		INNER JOIN DC.[Schema] AS s ON de.SchemaID = s.SchemaID
		INNER JOIN DC.[Database] AS d ON d.DatabaseID = s.DatabaseID
		INNER JOIN DC.[DatabaseInstance] AS di ON di.DatabaseInstanceID = d.DatabaseInstanceID
		INNER JOIN DC.[Server] AS se ON se.ServerID = di.ServerID
		INNER JOIN DC.[System] AS sy ON sy.SystemID = COALESCE(d.SystemID, s.SystemID)
		WHERE de.DataEntityID = @Source_DataEntityID
		AND sy.SystemID = @Source_SystemID
		AND s.SchemaID = @Source_SchemaID

		--SELECT * FROM @MatchingTable

		DECLARE @BKHashTable TABLE (ODS_DataEntityID INT, ODS_DataEntityName VARCHAR(250), ODS_FieldID INT,ODS_FieldName VARCHAR(250), FieldSortOrder INT)
		
		INSERT INTO @BKHashTable (ODS_DataEntityID , ODS_DataEntityName, ODS_FieldID , ODS_FieldName, FieldSortOrder )
		SELECT 
		sq.ODS_DataEntityID, de.DataEntityName, sq.ODS_FieldID, f.FieldName, f.FieldSortOrder
		FROM
		(
		SELECT DISTINCT
		 DC.udf_get_ODSDataEntityID_From_SourceDataEntityID(de.DataEntityID) AS ODS_DataEntityID
		,DC.udf_get_ODSFieldID_From_SourceFieldID(f.FieldID) AS ODS_FieldID
		FROM	
	   DMOD.[Hub] AS h
    INNER JOIN 
	   DMOD.[HubBusinessKey] AS hbk
		  ON hbk.[HubID] = h.[HubID]
    INNER JOIN 
	   DMOD.[HubBusinessKeyField] AS hbkf
		  ON hbkf.[HubBusinessKeyID] = hbk.[HubBusinessKeyID]
    INNER JOIN 
	   DC.[Field] AS f
		  ON hbkf.FieldID = f.FieldID
	INNER JOIN 
		DC.[DataEntity] AS de
	ON 
		de.DataEntityID = f.DataEntityID
	INNER JOIN
		@MatchingTable AS mt
	ON mt.DataEntityID = de.DataEntityID
	WHERE 
		--mt.RowType = 'Source'
				[h].[IsActive] = 1
		AND [hbk].[IsActive] = 1
		AND [hbkf].[IsActive] = 1
		) AS sq
		INNER JOIN 
		DC.Field AS f
		ON f.DataEntityID = sq.ODS_DataEntityID
		AND f.FieldID = sq.ODS_FieldID
		INNER JOIN 
		DC.DataEntity AS de
		ON de.DataEntityID = f.DataEntityID
		--ORDER BY f.FieleSortOrder



	-- DETERMINE WHAT TO DO
	DECLARE @DataEntityCount INT, @DataEntityCount_DISTINCT INT
	SELECT @DataEntityCount =  COUNT(DISTINCT ODS_DataEntityID) FROM @BKHashTable
    SELECT @DataEntityCount_DISTINCT =  COUNT(DISTINCT ODS_FieldID) FROM @BKHashTable

	


DECLARE @FieldList VARCHAR(MAX) = ''
SELECT @FieldList = @FieldList + '--!~ Field List with alias - ODS' + CHAR(13)

-- COLUMNS FROM THE SAME TABLE
IF (@DataEntityCount_DISTINCT = 1) 
BEGIN
    IF (@DataEntityCount = 1) 
    BEGIN
	   
		SELECT @FieldList = @FieldList + ' [' + 'StandardAlias' + CONVERT(VARCHAR(4), '1') + '].[' + bk.ODS_FieldName + '],'  + CHAR(13)
		FROM
		@BKHashTable AS bk
		ORDER BY bk.FieldSortOrder
		
    
    END
		  
    ELSE IF (@DataEntityCount > 1)
    BEGIN 
	   			
	SELECT @FieldList = @FieldList + ' [' + 'StandardAlias' + CONVERT(VARCHAR(4), '1') + '].[' + bk.ODS_FieldName + '],' + CHAR(13)
		FROM
		@BKHashTable AS bk
		ORDER BY bk.FieldSortOrder

	   END	

END

ELSE IF (@DataEntityCount_DISTINCT > 1) 
BEGIN

   DECLARE @DataEntityID AS INT
   DECLARE @StandardAlias_Number AS INT

	SELECT @FieldList = @FieldList + ' [' + 'StandardAlias' + CONVERT(VARCHAR(4), bkdr.StandardAlias_Number) + '].[' + bk.ODS_FieldName + '],' + CHAR(13)  
	FROM
	@BKHashTable AS bk
	INNER JOIN 
	(   
		SELECT 
			bkd.ODS_DataEntityID, ROW_NUMBER() OVER( ORDER BY bkd.ODS_DataEntityName ASC) AS StandardAlias_Number
		FROM (
				SELECT DISTINCT bk.ODS_DataEntityID, bk.ODS_DataEntityName
				FROM @BKHashTable AS bk
			) AS bkd
	) bkdr
	ON bkdr.ODS_DataEntityID = bk.ODS_DataEntityID
	ORDER BY bk.FieldSortOrder

    


END

ELSE 
BEGIN
    SELECT @FieldList = @FieldList + ''
END

SELECT @FieldList = @FieldList + '-- End of Field List with alias - ODS ~!'

RETURN @FieldList

END
/*
PRINT @FieldList

*/

GO
