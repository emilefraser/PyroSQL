SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Emile Fraser
-- Create Date: 10 June 2019
-- Description: Generate a JOIN LIST for a select statement from the ODS area table with a standard alias prefix

--!~ Hub & Link Hash Key Columns for ODS Select
/*
			--!~ Hub & Link table joins for ODS Select
			LEFT JOIN ODS_XT900.dbo.DEPARTMENT StandardAlias2 ON
				StandardAlias2.DPT_CODEID = StandardAlias.DPT_CODEID
			-- End of Hub & Link table joins for ODS Select ~!
			10417	47040

			select * from dmod.loadconfig
-- =============================================
--46987 47075
-- SELECT [DMOD].[udf_get_JoinList_WithAlias_ODS](10417)
-- SELECT * FROM DC.DataEntity WHERE DataEntityID = 47075
*/
CREATE FUNCTION [DMOD].[udf_get_JoinList_WithAlias_ODS_External]
(
	@ODS_DataEntityID INT
)  
RETURNS VARCHAR(MAX)
AS
BEGIN
		
	--DECLARE @ODS_DataEntityID INT = 46998
	
   -- Initial Value
	DECLARE @FieldList VARCHAR(MAX) = ''
	DECLARE @Source_DataEntityID INT = NULL
	DECLARE @Source_SystemID INT = NULL  
	DECLARE @Source_SchemaID INT = NULL

    DECLARE @Seperator VARCHAR(1) = '.'

	DECLARE @JoinTable TABLE 
	(
		  HubName VARCHAR(250), PKFKLinkID INT, PKFKLinkFieldID INT, FieldSortOrder INT
		, FieldID_PK INT, FieldName_PK VARCHAR(250), DataEntityID_PK INT, DataEntityName_PK VARCHAR(250), SchemaName_PK VARCHAR(250), DatabaseName_PK VARCHAR(250)
		, FieldID_FK INT, FieldName_FK VARCHAR(250), DataEntityID_FK INT, DataEntityName_FK VARCHAR(250), SchemaName_FK VARCHAR(250), DatabaseName_FK VARCHAR(250)
	)
	INSERT INTO @JoinTable
	(
		  HubName, PKFKLinkID, PKFKLinkFieldID, FieldSortOrder
		, FieldID_PK, FieldName_PK, DataEntityID_PK, DataEntityName_PK, SchemaName_PK, DatabaseName_PK
		, FieldID_FK, FieldName_FK, DataEntityID_FK, DataEntityName_FK, SchemaName_FK, DatabaseName_FK  
	)
	SELECT  
		  h.HubName, pkfk.PKFKLinkID, pkfkf.PKFKLinkFieldID
		, RANK() OVER (ORDER BY fpkfkf_fk.FieldSortOrder ASC) AS FieldSortOrder
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
		WHERE 
			fpkfkf_fk.DataEntityID = @ODS_DataEntityID
		AND
			h.IsActive = 1
		AND
			pkfk.IsActive = 1
		AND
			pkfkf.IsActive = 1


		-- Count of DISTINCT Data Entitiy
		DECLARE @DataEntityCount_DISTINCT INT = (SELECT COUNT(1) FROM @JoinTable)


		SELECT @FieldList = @FieldList + char(9) + char(9) + char(9) + '--!~ Hub & Link table joins for ODS Select'  + CHAR(13)+CHAR(10) 

		-- No Join Tables
		IF (@DataEntityCount_DISTINCT = 0) 
		BEGIN
			SELECT @FieldList = @FieldList + '' + CHAR(13) + CHAR(10)
		END
		  
		ELSE IF @DataEntityCount_DISTINCT > 0
		BEGIN 	    	 
			SELECT @FieldList = @FieldList + char(9) + char(9) + char(9) 
				+ ' LEFT JOIN ' + '[' + 'ext_' + DatabaseName_PK + '_' +  SchemaName_PK + '_' +  DataEntityName_PK  + ']' + 
				+ ' AS StandardAlias' + CONVERT(VARCHAR(4), FieldSortOrder+1)  
				+ CHAR(13)+CHAR(10) 
				+ char(9) + char(9) + char(9) + char(9)
				+ ' ON ' 
				+ 'StandardAlias' + CONVERT(VARCHAR(4), FieldSortOrder+1) 
				+ @Seperator
				+ '['
				+ FieldName_PK
				+ ']'
				+ ' = '
				+ 'StandardAlias' + CONVERT(VARCHAR(4), 1) 
				+ @Seperator
				+ '['
				+  FieldName_FK
				+ ']'
				+ CHAR(13)+CHAR(10) 
			FROM 
				@JoinTable
			ORDER BY 
				FieldSortOrder

			   END

	   
		ELSE 
		BEGIN
			   SELECT @FieldList = @FieldList + ''
		END

			SELECT @FieldList = @FieldList + char(9) + char(9) + char(9) + '-- End of Hub & Link table joins for ODS Select ~!'

			

			/*
			SELECT @FieldList
		
		*/
			RETURN @FieldList
		
			
		END
	

GO
