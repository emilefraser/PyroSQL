SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

 --Author:      Emile Fraser
 --Create Date: 6 June 2019
 --Description: Generate a Field list for a select statement from the ODS area table with a standard alias prefix


-- SELECT [DMOD].[udf_get_FieldList_WithAlias_ODS](55)
-- SELECT [DMOD].[udf_get_FieldList_WithAlias_ODS](96)

CREATE FUNCTION [DMOD].[udf_get_FieldList_WithAlias_ODS]
(
    @LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	--DECLARE @ODS_DataEntityID INT = (SELECT [DC].[udf_get_SourceSystem_DataEntityID](@Stage_DataEntityID))
	DECLARE @ODS_DataEntityID INT = (SELECT [DMOD].[udf_get_LoadConfig_SourceDataEntityID](@LoadConfigID))
	DECLARE @Stage_DataEntityID INT = (SELECT [DMOD].[udf_get_LoadConfig_TargetDataEntityID](@LoadConfigID))
	
	--DECLARE @EntityName AS VARCHAR(100) = (SELECT DataEntityName FROM [DC].[DataEntity] WHERE DataEntityID = @Stage_DataEntityID)
	--DECLARE @EntityType AS VARCHAR(4) = (SELECT SUBSTRING(@EntityName, LEN(@EntityName) - 3, 4))
	DECLARE @EntityType AS VARCHAR(100) = 
	(
		SELECT 
			DataEntityTypeCode
		FROM 
			DMOD.LoadConfig AS lc
		INNER JOIN 
			DMOD.LoadType AS lt 
		ON 
			lc.LoadTypeID = lt.LoadTypeID
		INNER JOIN 
			DC.DataEntityType AS det
		ON 
			det.DataEntityTypeID = lt.DataEntityTypeID
		WHERE 
			lc.LoadConfigID = @LoadConfigID
	)


	DECLARE @ODS_FieldListReturn TABLE (DataEntityID INT, DataEntityName VARCHAR(100), FieldID INT, FieldName VARCHAR(100), FieldSortOrder INT)

	IF(@EntityType = 'KEYS') 
	BEGIN
		INSERT INTO  @ODS_FieldListReturn (DataEntityID ,DataEntityName, FieldID , FieldName , FieldSortOrder )
		SELECT f.DataEntityID, de.DataEntityName, f.FieldID, f.FieldName, hbk.FieldSortOrder
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
				  ON de.DataEntityID = f.DataEntityID
			WHERE 
				f.DataEntityID IN (@ODS_DataEntityID)
			AND 
				ISNULL(h.IsActive, 0) = 1
			AND 
				ISNULL(hbk.IsActive, 0) = 1
			AND
				ISNULL(hbkf.IsActive, 0) = 1
			ORDER BY 
				f.FieldSortOrder
	END
	ELSE
	BEGIN
		INSERT INTO  @ODS_FieldListReturn (DataEntityID , DataEntityName, FieldID , FieldName , FieldSortOrder )
		SELECT Sf.DataEntityID, de.DataEntityName, Sf.FieldID, Sf.FieldName, Sf.FieldSortOrder
		FROM	
			   DMOD.[Hub] AS h
			INNER JOIN 
				DMOD.[Satellite] AS sat
				ON sat.HubID = h.HubID
			INNER JOIN 
				DMOD.[SatelliteField] AS satf
				ON satf.SatelliteID = sat.SatelliteID
			 INNER JOIN 
				DC.[Field] AS sf
				ON sf.FieldID = satf.FieldID
			INNER JOIN
				DC.[DataEntity] AS de
				ON de.DataEntityID = sf.DataEntityID
			WHERE	
				sf.DataEntityID IN (@ODS_DataEntityID)
			AND 
				ISNULL(h.IsActive, 0) = 1
			AND 
				ISNULL(sat.IsActive, 0) = 1
			AND
				ISNULL(satf.IsActive, 0) = 1
			ORDER BY 
				sf.FieldSortOrder
	END

	
DECLARE @DataEntityCount_DISTINCT INT = (SELECT COUNT(DISTINCT DataEntityID) FROM @ODS_FieldListReturn)
DECLARE @DataEntityCount INT = (SELECT COUNT(DataEntityID) FROM @ODS_FieldListReturn)

DECLARE @FieldList VARCHAR(MAX) = ''
SELECT @FieldList = @FieldList + '--!~ Field List with alias - ODS' + CHAR(13)

-- COLUMNS FROM THE SAME TABLE
IF (@DataEntityCount_DISTINCT = 1) 
BEGIN
    IF (@DataEntityCount = 1) 
    BEGIN
	   
		SELECT @FieldList = @FieldList + ' [' + 'StandardAlias' + CONVERT(VARCHAR(4), '1') + '].[' + bk.FieldName + '],'  + CHAR(13)
		FROM
		@ODS_FieldListReturn AS bk
		ORDER BY bk.FieldSortOrder
		
    
    END
		  
    ELSE IF (@DataEntityCount > 1)
    BEGIN 
	   			
	SELECT @FieldList = @FieldList + ' [' + 'StandardAlias' + CONVERT(VARCHAR(4), '1') + '].[' + bk.FieldName + '],' + CHAR(13)
		FROM
		@ODS_FieldListReturn AS bk
		ORDER BY bk.FieldSortOrder

	   END	

END

ELSE IF (@DataEntityCount_DISTINCT > 1) 
BEGIN

   DECLARE @DataEntityID AS INT
   DECLARE @StandardAlias_Number AS INT

	SELECT @FieldList = @FieldList + ' [' + 'StandardAlias' + CONVERT(VARCHAR(4), bkdr.StandardAlias_Number) + '].[' + bk.FieldName + '],' + CHAR(13)  
	FROM
	@ODS_FieldListReturn AS bk
	INNER JOIN 
	(   
		SELECT 
			bkd.DataEntityID, ROW_NUMBER() OVER( ORDER BY bkd.DataEntityName ASC) AS StandardAlias_Number
		FROM (
				SELECT DISTINCT bk.DataEntityID, bk.DataEntityName
				FROM @ODS_FieldListReturn AS bk
			) AS bkd
	) bkdr
	ON bkdr.DataEntityID = bk.DataEntityID
	ORDER BY bk.FieldSortOrder

    


END

ELSE 
BEGIN
    SELECT @FieldList = @FieldList + '' + CHAR(13)  
END

	SELECT @FieldList = LEFT(@FieldList, LEN(@FieldList) - 2) + CHAR(13)

SELECT @FieldList = @FieldList + '-- End of Field List with alias - ODS ~!'


RETURN @FieldList

END

/*
PRINT @FieldList
*/

GO
