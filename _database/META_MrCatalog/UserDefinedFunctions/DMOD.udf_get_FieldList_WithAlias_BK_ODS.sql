SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
 Author:      Emile Fraser
 Create Date: 6 June 2019
 Description: Generate a Field list for a select statement from the ODS area table with a standard alias prefix

--!~ StageArea BK Hash Column Calculation from ODS
				BKHash = CONVERT	(VARCHAR(40),
							HASHBYTES	('SHA1',
									CONVERT	(VARCHAR(MAX),
											COALESCE(UPPER(LTRIM(RTRIM(StandardAlias.EMP_EMPNO))),'')
											)
										)
								,2)
-- End of StageArea BK Hash Column Calculation from ODS ~!

	SELECT * FROM DMOD.vw_LoadConfig

	SELECT [DMOD].[udf_get_FieldList_WithAlias_BK_ODS](55)
	SELECT [DMOD].[udf_get_FieldList_WithAlias_BK_ODS](611)


*/
CREATE FUNCTION [DMOD].[udf_get_FieldList_WithAlias_BK_ODS]
(
    @LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @ODS_DataEntityID INT = (SELECT [DMOD].[udf_get_LoadConfig_SourceDataEntityID](@LoadConfigID))

	--DECLARE @ODS_DataEntityID INT = 47095
	DECLARE @BKHashTable TABLE 
	(
		ODS_DataEntityID INT
	,	ODS_DataEntityName VARCHAR(250)
	,	ODS_FieldID INT
	,	ODS_FieldName VARCHAR(250)
	,	FieldSortOrder INT
	)
	INSERT INTO @BKHashTable
	(
		   [ODS_DataEntityID]
		 , [ODS_DataEntityName]
		 , [ODS_FieldID]
		 , [ODS_FieldName]
		 , [FieldSortOrder]
	)
	SELECT
		   [fhbkf].[DataEntityID]
		 , [de].[DataEntityName]
		 , [fhbkf].[FieldID]
		 , [fhbkf].[FieldName]
		 , [hbk].[FieldSortOrder]
	FROM
		 [DMOD].[Hub] AS [h]
	INNER JOIN
		[DMOD].[HubBusinessKey] AS [hbk]
		ON [hbk].[HubID] = [h].[HubID]
	INNER JOIN
		[DMOD].[HubBusinessKeyField] AS [hbkf]
		ON [hbkf].[HubBusinessKeyID] = [hbk].[HubBusinessKeyID]
	INNER JOIN
		[DC].[Field] AS [fhbkf]
		ON [fhbkf].[FieldID] = [hbkf].[FieldID]
	INNER JOIN
		[DC].[DataEntity] AS [de]
		ON [fhbkf].[DataEntityID] = [de].[DataEntityID]
	WHERE 
		[fhbkf].[DataEntityID] = @ODS_DataEntityID
	AND
		h.IsActive = 1
	AND
		hbk.IsActive = 1
	AND
		hbkf.IsActive = 1

	-- DETERMINE WHAT TO DO
	DECLARE @DataEntityCount INT, @DataEntityCount_DISTINCT INT
	SELECT @DataEntityCount =  COUNT(DISTINCT ODS_DataEntityID) FROM @BKHashTable
    SELECT @DataEntityCount_DISTINCT =  COUNT(DISTINCT ODS_FieldID) FROM @BKHashTable

	
	DECLARE @FieldList VARCHAR(MAX) = ''
	SELECT @FieldList = @FieldList + '--!~ StageArea BK Hash Column Calculation from ODS' + CHAR(13)

	-- COLUMNS FROM THE SAME TABLE
	IF (@DataEntityCount_DISTINCT = 1) 
	BEGIN
		IF (@DataEntityCount = 1) 
		BEGIN
	 
			SELECT @FieldList = @FieldList + ' CONVERT(VARCHAR(40),' + CHAR(13)
			+ REPLICATE(CHAR(9),5) + ' HASHBYTES (''SHA1'',' + CHAR(13)
			+ REPLICATE(CHAR(9),6) + ' CONVERT	(VARCHAR(MAX),' + CHAR(13)
			+ REPLICATE(CHAR(9),7) + ' COALESCE(UPPER(LTRIM(RTRIM(' + QUOTENAME('StandardAlias' + CONVERT(VARCHAR(4), '1')) + '.' + QUOTENAME(bk.ODS_FieldName) + '))),''''))' + CHAR(13)
			+ REPLICATE(CHAR(9),6) + ' )' + CHAR(13)
			+ REPLICATE(CHAR(9),5) + ' ,2)' + CHAR(13)
			FROM
				@BKHashTable AS bk	
			ORDER BY 
				bk.[FieldSortOrder]
    
		END
		  
		ELSE IF (@DataEntityCount > 1)
		BEGIN 
	   			
			SELECT @FieldList = @FieldList + ' CONVERT(VARCHAR(40),' + CHAR(13) + REPLICATE(CHAR(9),5) + ' HASHBYTES (''SHA1'',' + CHAR(13)

			SELECT @FieldList = @FieldList +
	  		+ REPLICATE(CHAR(9),6) + '  CONVERT	(VARCHAR(MAX),' + CHAR(13)
			+ REPLICATE(CHAR(9),7) + '  COALESCE(UPPER(LTRIM(RTRIM(' + QUOTENAME('StandardAlias' + CONVERT(VARCHAR(4), '1')) + '.' + QUOTENAME(bk.ODS_FieldName) + '))),'''')) + ''|'' +' + CHAR(13)
			FROM
				@BKHashTable AS bk
			ORDER BY 
				bk.[FieldSortOrder]

		   IF (@FieldList != '')
			  SET @FieldList = LEFT(@FieldList, LEN(@FieldList) - 9)

			SELECT @FieldList = @FieldList + CHAR(13)
			+ REPLICATE(CHAR(9),6) + ' )' + CHAR(13)
			+ REPLICATE(CHAR(9),5)+ ' ,2) AS BKHash' + CHAR(13)

		END	

	END

	ELSE IF (@DataEntityCount_DISTINCT > 1) 
	BEGIN

	   DECLARE @DataEntityID AS INT
	   DECLARE @StandardAlias_Number AS INT

		SELECT @FieldList = @FieldList + ' CONVERT(VARCHAR(40),' + CHAR(13) + REPLICATE(CHAR(9),5) + ' HASHBYTES (''SHA1'',' + CHAR(13)

		SELECT @FieldList = @FieldList + CHAR(13)
		+ REPLICATE(CHAR(9),6) + '  CONVERT	(VARCHAR(MAX),' + CHAR(13)
		+ REPLICATE(CHAR(9),7)+ '  COALESCE(UPPER(LTRIM(RTRIM(' + QUOTENAME('StandardAlias' + CONVERT(VARCHAR(4), bkdr.StandardAlias_Number)) + '.' + QUOTENAME(bk.ODS_FieldName) + '))),'''')) + ''|'' +' + CHAR(13)  
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
		ORDER BY 
				bk.[FieldSortOrder]

		  IF @FieldList != ''
			   SET @FieldList = LEFT(@FieldList, LEN(@FieldList) - 9)


			SELECT @FieldList = @FieldList + CHAR(13)
			+ REPLICATE(CHAR(9),6) + ' )' + CHAR(13)
			+ REPLICATE(CHAR(9),5)+ ' ,2) AS BKHash' + CHAR(13)

	END

	ELSE 
	BEGIN
		SELECT @FieldList = @FieldList + ''
	END

SELECT @FieldList = @FieldList + '-- End of StageArea BK Hash Column Calculation from ODS ~!'
/*
PRINT @FieldList
*/
RETURN @FieldList

END

GO
