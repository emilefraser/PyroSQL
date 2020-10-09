SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
--Author:      Emile Fraser
 --Create Date: 6 June 2019
 --Description: Generate a Field list for a select statement from the ODS area table with a standard alias prefix


-- SELECT [DMOD].[udf_get_FieldList_WithAlias_ODS](55)
-- SELECT [DMOD].[udf_get_FieldList_WithAlias_ODS](3806)

-- SELECT [DMOD].[udf_get_FieldList_WithoutAlias_BK_DV] (3806)
-- SELECT [DMOD].[udf_get_FieldList_WithoutAlias_BK_DV] (3807)
/**/
CREATE FUNCTION [DMOD].[udf_get_FieldList_WithoutAlias_BK_DV]
(
    @LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN


	--DECLARE @LoadConfigID INT = 3359
	 
	DECLARE @Stage_DataEntityID INT = (SELECT [DMOD].[udf_get_LoadConfig_SourceDataEntityID](@LoadConfigID))
	--DECLARE @ODS_DataEntityID INT = (SELECT [DC].[udf_get_SourceSystem_DataEntityID](@Stage_DataEntityID))
	DECLARE @ODS_DataEntityID INT = (SELECT SourceDataEntityID FROM DMOD.LoadConfig WHERE TargetDataEntityID = @Stage_DataEntityID)

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


	DECLARE @ODS_FieldListReturn TABLE (DataEntityID INT, DataEntityName VARCHAR(100), FieldID INT, FieldName VARCHAR(100), FriendlyName VARCHAR(200),  FieldSortOrder INT)

	--SELECT @EntityType

	IF(@EntityType = 'HUB' OR @EntityType = 'REF') 
	BEGIN
		INSERT INTO  @ODS_FieldListReturn (DataEntityID ,DataEntityName, FieldID , FieldName, FieldSortOrder, FriendlyName )
		SELECT f.DataEntityID, de.DataEntityName, f.FieldID, f.FieldName, hbk.FieldSortOrder, hbk.BKFriendlyName
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
	ELSE IF(@EntityType = 'LINK') 
	BEGIN
		INSERT INTO  @ODS_FieldListReturn (DataEntityID ,DataEntityName, FieldID , FieldName, FieldSortOrder, FriendlyName )
		SELECT f.DataEntityID, de.DataEntityName, f.FieldID, f.FieldName, hbk.FieldSortOrder, hbk.BKFriendlyName
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
	ELSE IF (@EntityType = 'SATLVD' OR @EntityType = 'SATMVD' OR @EntityType = 'SATHVD' or @EntityType = 'REFSAT')
	BEGIN
		INSERT INTO  @ODS_FieldListReturn (DataEntityID , DataEntityName, FieldID , FieldName , FieldSortOrder, FriendlyName )
		SELECT Sf.DataEntityID, de.DataEntityName, Sf.FieldID, Sf.FieldName, Sf.FieldSortOrder, sf.FieldName
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

	--SELECT * FROM @ODS_FieldListReturn
	--DECLARE @DataEntityCount_DISTINCT INT = (SELECT COUNT(DISTINCT DataEntityID) FROM @ODS_FieldListReturn)
	--DECLARE @DataEntityCount INT = (SELECT COUNT(DataEntityID) FROM @ODS_FieldListReturn)

	DECLARE @FieldList VARCHAR(MAX) = ''
	SELECT @FieldList = @FieldList + '--!~ Field List without alias of Business Keys for DataVault' + CHAR(13)

-- COLUMNS FROM THE SAME TABLE
	IF(@EntityType = 'HUB') 
	BEGIN
		SELECT 
			@FieldList = @FieldList + CHAR(9) + CHAR(9) + ', [' + bk.FriendlyName + ']'  + CHAR(13)
		FROM
			@ODS_FieldListReturn AS bk
		ORDER BY 
			bk.FieldSortOrder
	END
	ELSE IF (@EntityType = 'LINK') 
	BEGIN
		SELECT 
			@FieldList = @FieldList + CHAR(9) + CHAR(9) + ', [' + bk.FriendlyName + ']'  + CHAR(13)
		FROM
			@ODS_FieldListReturn AS bk
		ORDER BY 
			bk.FieldSortOrder

	END
	ELSE
	BEGIN
		SELECT 
			@FieldList = @FieldList + CHAR(9) + CHAR(9) + ', [' + bk.FriendlyName + ']'  + CHAR(13)
		FROM
			@ODS_FieldListReturn AS bk
		ORDER BY 
			bk.FieldSortOrder
	END
		

	--SELECT @FieldList = LEFT(@FieldList, LEN(@FieldList) - 2) + CHAR(13)

	SELECT @FieldList = @FieldList + '-- End of Field List without alias of Business Keys for DataVault ~!'

RETURN @FieldList

END
/*
PRINT @FieldList
*/

GO
