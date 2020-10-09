SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Emile Fraser
-- Create Date: 10 June 2019
-- Description: Generate a JOIN LIST for a select statement from the ODS area table with a standard alias prefix

--!~ Hub & Link Hash Key Columns for ODS Select
/*
SELECT 

		select * from dmod.vw_loadconfig
-- =============================================
	--DECLARE @ODS_DataEntityID INT = 49945
-- SELECT [DMOD].[udf_get_JoinList_WithAlias_ODS](55)
-- SELECT [DMOD].[udf_get_JoinList_WithAlias_ODS](19)
*/	

CREATE   FUNCTION [DMOD].[udf_get_JoinList_WithAlias_ODS] 
(
	@LoadConfigID INT
)  
RETURNS VARCHAR(MAX)
AS
BEGIN
	-- :>DEBUG
	--DECLARE @LoadConfigID INT = 29
	-- DEBUG::

	-- Get Source and Target DE
	DECLARE @ODS_DataEntityID INT = (SELECT [DMOD].[udf_get_LoadConfig_SourceDataEntityID](@LoadConfigID))
	DECLARE @Stage_DataEntityID INT = (SELECT [DMOD].[udf_get_LoadConfig_TargetDataEntityID](@LoadConfigID))
	
	-- :>DEBUG
	-- SELECT @ODS_DataEntityID, @Stage_DataEntityID
	-- DEBUG::
	
   -- Initial Value
	DECLARE @FieldList VARCHAR(MAX) = ''
	DECLARE @Source_DataEntityID INT = NULL
	DECLARE @Source_SystemID INT = NULL  
	DECLARE @Source_SchemaID INT = NULL
	

    DECLARE @Seperator VARCHAR(1) = '.'
	DECLARE @Source_DatabaseID INT = (SELECT DC.udf_get_DatabaseID_from_DataEntityID(@ODS_DataEntityID))
	DECLARE @Source_DatabaseName VARCHAR(MAX) = (SELECT db.DatabaseName FROM DC.[Database] AS db WHERE db.DatabaseID = @Source_DatabaseID)
	DECLARE @Source_SchemaName VARCHAR(MAX) = (SELECT DC.udf_GetSchemaNameForDataEntityID(@Source_DataEntityID))

	--:>DEBUG
	-- SELECT @ODS_DataEntityID AS ODS_DataEntityID_DEBUG, @Source_DatabaseID AS Source_DatabaseID_DEBUG
	--DEBUG>:

	-- :DEBUG:
	--		SELECT @HubID
	--		SELECT HubName FROM DMOD.Hub WHERE HubID = @HubID
	-- :DEBUG:
	-- GEt the FieldSortOrder to Align the Joins to the Actual order of the HK Gen
	DECLARE @LinkTableSort TABLE (FieldID VARCHAR(255), FieldName VARCHAR(250), FieldSortOrder INT)
	INSERT INTO @LinkTableSort(FieldID, FieldName, FieldSortOrder)
	SELECT f.FieldID, f.FieldName, f.FieldSortOrder
	FROM DC.Field AS f
	WHERE f.dataentityid = @Stage_DataEntityID
	ORDER BY f.fieldSortorder

	--:>DEBUG
	--SELECT * FROM @LinkTableSort
	--DEBUG>:

	DECLARE @JoinTable TABLE 
	(
		  HubName VARCHAR(250), PKFKLinkID INT, PKFKLinkFieldID INT, FieldSortOrder INT, JoinNumber INT, TableAliasNumber INT 
		, FieldID_PK INT, FieldName_PK VARCHAR(250), DataEntityID_PK INT, DataEntityName_PK VARCHAR(250), SchemaName_PK VARCHAR(250), DatabaseName_PK VARCHAR(250)
		, FieldID_FK INT, FieldName_FK VARCHAR(250), DataEntityID_FK INT, DataEntityName_FK VARCHAR(250), SchemaName_FK VARCHAR(250), DatabaseName_FK VARCHAR(250)
	)
	INSERT INTO @JoinTable
	(
		  HubName, PKFKLinkID, PKFKLinkFieldID, FieldSortOrder, JoinNumber, TableAliasNumber
		, FieldID_PK, FieldName_PK, DataEntityID_PK, DataEntityName_PK, SchemaName_PK, DatabaseName_PK
		, FieldID_FK, FieldName_FK, DataEntityID_FK, DataEntityName_FK, SchemaName_FK, DatabaseName_FK  
	)

	SELECT  
		  h.HubName, pkfk.PKFKLinkID, pkfkf.PKFKLinkFieldID
		,	RANK() OVER (ORDER BY ss.FieldSortOrder ASC) AS FieldSortOrder
		,	DENSE_RANK() OVER(ORDER BY ss.FieldSortOrder ASC) AS JoinNumber
		,	DENSE_RANK() OVER(ORDER BY ss.FieldSortOrder ASC) + 1 AS TableAliasNumber
		, fpkfkf_pk.FieldID, fpkfkf_pk.FieldName, fpkfkf_pk.DataEntityID, depk.DataEntityName, spk.SchemaName, dpk.DatabaseName
		, fpkfkf_fk.FieldID, fpkfkf_fk.FieldName, fpkfkf_fk.DataEntityID, defk.DataEntityName, sfk.SchemaName, dfk.DatabaseName
		FROM 
			DMOD.Hub AS h
		INNER JOIN 
			DMOD.PKFKLink AS pkfk
			ON pkfk.ParentHubID = h.HubID
		INNER JOIN 
			DMOD.PKFKLinkField AS pkfkf
			ON pkfkf.PKFKLinkID = pkfk.PKFKLinkID
		INNER JOIN 
			DC.[Field] AS fpkfkf_pk
			ON fpkfkf_pk.FieldID = pkfkf.PrimaryKeyFieldID
		INNER JOIN 
			DC.DataEntity AS depk
			ON depk.DataEntityID = fpkfkf_pk.DataEntityID
		INNER JOIN 
			DC.[Schema] AS spk
			ON spk.SchemaID = depk.SchemaID
		INNER JOIN 
			DC.[Database] AS dpk
			ON dpk.DatabaseID = spk.DatabaseID
		INNER JOIN 
			DC.[Field] AS fpkfkf_fk
			ON fpkfkf_fk.FieldID = pkfkf.ForeignKeyFieldID
		INNER JOIN 
			DC.DataEntity AS defk
			ON defk.DataEntityID = fpkfkf_fk.DataEntityID
		INNER JOIN 
			DC.[Schema] AS sfk
			ON sfk.SchemaID = defk.SchemaID
		INNER JOIN 
			DC.[Database] AS dfk
			ON dfk.DatabaseID = sfk.DatabaseID
		INNER JOIN
				@LinkTableSort AS ss
			ON 
				REPLACE(pkfk.LinkName, 'LINK_', 'LINKHK_') = ss.FieldName
		WHERE 
			fpkfkf_fk.DataEntityID = @ODS_DataEntityID
		AND
			h.IsActive = 1
		AND
			pkfk.IsActive = 1
		AND
			pkfkf.IsActive = 1

		-- :>DEBUG
		-- Shows the @JoinTable Output
		-- SELECT * FROM @JoinTable
		-- DEBUG::

		-- Count of DISTINCT Data Entitiy
		DECLARE @DataEntityCount INT = (SELECT COUNT(1) FROM @JoinTable)
		DECLARE @DataEntityCount_DISTINCT INT = (SELECT COUNT (DISTINCT DataEntityID_PK) FROM @JoinTable)

		-- :>DEBUG
		-- SELECT @DataEntityCount AS DEBUG_DataEntityCount,  @DataEntityCount_DISTINCT AS DataEntityCount_DISTINCT
		-- DEBUG::

		SELECT @FieldList = @FieldList + REPLICATE(char(9), 3) + '--!~ Hub & Link table joins for ODS Select'  + CHAR(13)+CHAR(10) 

		-- No Join Tables
		IF (@DataEntityCount = 0) 
		BEGIN
			SELECT @FieldList = @FieldList + '' + CHAR(13) + CHAR(10)
		END
		  
		ELSE IF @DataEntityCount > 0
		BEGIN 	    	
		
			DECLARE @totalloops INT = (SELECT MAX(JoinNumber) FROM @JoinTable)

			DECLARE @currentloop INT  = 1
				WHILE @currentloop <= @totalloops
				BEGIN

					-- The First Portion of the Join Tables
					SELECT @FieldList = @FieldList + REPLICATE(CHAR(9),3)
						+ ' LEFT JOIN ' + '[' + jts.DatabaseName_PK + ']' + @Seperator + '[' + jts.SchemaName_PK + ']' + @Seperator + '[' + jts.DataEntityName_PK  + ']'
						+ ' AS StandardAlias' + CONVERT(VARCHAR(4), jts.JoinNumber + 1)  
						+ CHAR(13) + CHAR(10) 
						+ REPLICATE(CHAR(9), 4)
						+ ' ON ' 
					FROM 
						(
							SELECT DISTINCT 
								DataEntityName_PK, SchemaName_PK, DatabaseName_PK, JoinNumber
							FROM @JoinTable
						) AS jts
					WHERE 
						jts.JoinNumber = @currentloop
					ORDER BY 
						jts.JoinNumber

					-- The ON Portion Including the possibility of having mutiple join clauses
					SELECT @FieldList = @FieldList
						+ 'StandardAlias' + CONVERT(VARCHAR(4), jt.TableAliasNumber) 
						+ @Seperator
						+ '['
						+ jt.FieldName_PK
						+ ']'
						+ ' = '
						+ 'StandardAlias' + CONVERT(VARCHAR(4), 1) 
						+ @Seperator
						+ '['
						+  jt.FieldName_FK
						+ ']'						
						+ CHAR(13)+CHAR(10) 
						+ REPLICATE(char(9),4)
						+ ' AND '
					FROM 
						@JoinTable AS jt
					WHERE 
						JoinNumber = @currentloop
					ORDER BY 
						FieldSortOrder

					SET @FieldList = LEFT(@FieldList, LEN(@FieldList) - 8)
					SET @currentloop = @currentloop + 1

				   END


				END
	   
		ELSE 
		BEGIN
			   SELECT @FieldList = @FieldList + ''
		END

			SELECT @FieldList = @FieldList + REPLICATE(char(9),3) + '-- End of Hub & Link table joins for ODS Select ~!'

			

			-- :>DEBUG
			-- SELECT @FieldList
			-- DEBUG>:
		
			RETURN @FieldList
		
			
		END

GO
