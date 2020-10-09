SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
-- =============================================
-- Author:      Emile Fraser
-- Create Date: 6 June 2019
-- Description: Generate a Field list for a select statement from the ODS area table with a standard alias prefix

	SELECT [DMOD].[udf_get_FieldList_WithAlias_HashDiff](55)
	SELECT [DMOD].[udf_get_FieldList_WithAlias_HashDiff](96)
*/

CREATE FUNCTION [DMOD].[udf_get_FieldList_WithAlias_HashDiff](
    @LoadConfigID INT)
RETURNS VARCHAR(MAX)
AS
BEGIN

		DECLARE @Satellite_DataEntityID INT = (SELECT [DMOD].[udf_get_LoadConfig_SourceDataEntityID](@LoadConfigID))

		DECLARE @FieldList AS VARCHAR(MAX) = ''

		DECLARE @SatelliteTable TABLE (HubName VARCHAR(255), SatelliteID INT, SatelliteName VARCHAR(255),SatelliteDataVelocityTypeID INT,
									SatelliteFieldID INT, FieldID INT, FieldName VARCHAR(255), DataEntityID INT, DataEntityName VARCHAR(255),
										FieldSortOrder INT)
		INSERT INTO @SatelliteTable (HubName , SatelliteID , SatelliteName ,SatelliteDataVelocityTypeID,
										SatelliteFieldID , FieldID , FieldName, DataEntityID , DataEntityName, FieldSortOrder)
		SELECT h.HubName, sat.SatelliteID, sat.SatelliteName, sat.SatelliteDataVelocityTypeID
					, satf.SatelliteFieldID, f.FieldID, f.FieldName, de.DataEntityID, de.DataEntityName, f.FieldSortOrder
		FROM 
			DMOD.Hub AS h
		INNER JOIN 
			DMOD.Satellite AS sat
			ON sat.HubID = h.HubID
		INNER JOIN 
			DMOD.SatelliteField AS satf
			ON satf.SatelliteID = sat.SatelliteID
		INNER JOIN
			DC.Field AS f
			ON f.FieldID = satf.FieldID
		INNER JOIN 
			DC.DataEntity AS de
			ON de.DataEntityID = f.DataEntityID
		WHERE 
			f.DataEntityID = @Satellite_DataEntityID
		AND 
			ISNULL(h.IsActive, 0) = 1
		AND 
			ISNULL(sat.IsActive, 0) = 1
		AND
			ISNULL(satf.IsActive, 0) = 1
			
			-- Return Builder
			SELECT @FieldList = @FieldList + '--!~ Get HashDiff for Satellite' + CHAR(13)

			SELECT @FieldList = @FieldList + ' CONVERT(VARCHAR(40),' + CHAR(13)
			+ CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + ' HASHBYTES (''SHA1'',' + CHAR(13)
			+ CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + '  CONVERT	(VARCHAR(MAX),' + CHAR(13)


			SELECT @FieldList = @FieldList +  REPLICATE(CHAR(9), 7) + ' COALESCE(UPPER(LTRIM(RTRIM([' + 'StandardAlias' + CONVERT(VARCHAR(4), 1) + '].[' + sat.FieldName + ']))),''NA'') + ''|'' + ' + CHAR(13)
			FROM @SatelliteTable AS sat
			ORDER BY sat.FieldSortOrder ASC
			
			SET @FieldList = LEFT(@FieldList, LEN(@FieldList) - 9) + CHAR(13)
			
			SELECT @FieldList = @FieldList + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + ' )' + CHAR(13)
			SELECT @FieldList = @FieldList + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + ' )' + CHAR(13)
			+ CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + ' ,2) AS [HashDiff],' + CHAR(13)

	SELECT @FieldList = @FieldList + '-- End of HashDiff for Satellite ~!' + CHAR(13)

	--PRINT @FieldList

	RETURN @FieldList
END

/*
RETURN @FieldList
END

PRINT @FieldList

RETURN @FieldList
END
*/

GO
