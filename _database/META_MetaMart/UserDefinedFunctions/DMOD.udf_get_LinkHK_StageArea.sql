SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
-- =============================================
-- Author:      Emile Fraser
-- Create Date: 9 September 2019
-- Description: Gets the LINKHKs for this specific Entity for Comparison (ONLY KEYS TABLES)

-- ~! Link HK comparisons for inserting into stage
				[StandardAlias1].[LINKHK_CategoryManager_Customer] <> [CompareHist].[LINKHK_CategoryManager_Customer]
			OR [StandardAlias1].[LINKHK_RelationshipManager_Customer] <> [CompareHist].[LINKHK_RelationshipManager_Customer]
-- End of Link HK comparisons for inserting into stage ~!
*/

CREATE FUNCTION [DMOD].[udf_get_LinkHK_StageArea](
    @LoadConfigID INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @ReturnString VARCHAR(MAX) = ''
	
	-- Pull this from DMOD and compare it against the current CompareHist Table that exists
	DECLARE @Stage_DataEntityID INT = (SELECT TargetDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)
	DECLARE @ODS_DataEntityID INT = (SELECT SourceDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)
	
	DECLARE @LinkTableSort TABLE (FieldID VARCHAR(255), FieldName VARCHAR(250), FieldSortOrder INT)
	INSERT INTO @LinkTableSort(FieldID, FieldName, FieldSortOrder)
	SELECT f.FieldID, f.FieldName, f.FieldSortOrder
	FROM DC.Field AS f
	WHERE f.dataentityid = @Stage_DataEntityID
	ORDER BY f.fieldSortorder
	
	DECLARE @LinkTable TABLE (HubName VARCHAR(255), PKFKLinkID INT, PKFKLinkFieldID INT,
									LinkName VARCHAR(255), SortOrder INT,
										 LinkHK_Name VARCHAR(255))
	INSERT INTO @LinkTable  (HubName , PKFKLinkID , PKFKLinkFieldID ,
									LinkName  , SortOrder , LinkHK_Name)
		
		

	SELECT    
			  h.HubName
			, pkfk.PKFKLinkID
			, pkfkf.PKFKLinkFieldID
			, pkfk.LinkName
			, RANK() OVER (ORDER BY ss.FieldSortOrder ASC) AS SortOrder
			, REPLACE(pkfk.LinkName, 'LINK_', 'LINKHK_') AS LinkHK_Name
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
				DC.[Field] AS fpkfkf_fk
				ON fpkfkf_fk.FieldID = pkfkf.ForeignKeyFieldID
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


	-- Start of putting together the return string
	SELECT @ReturnString = @ReturnString + '-- ~! Link HK comparisons for inserting into stage' +  CHAR(13)

	IF EXISTS (SELECT 1 FROM @LinkTable)
	BEGIN

		SELECT 
			@ReturnString = @ReturnString + ' OR ' + '[StandardAlias1].' + QUOTENAME(lt.[LinkHK_Name]) + ' <> ' + '[CompareHist].' + QUOTENAME(lt.[LinkHK_Name]) + CHAR(13)
		FROM 
			@LinkTable AS lt
		ORDER BY 
			lt.SortOrder ASC
	END
		
	SELECT @ReturnString = @ReturnString + '-- End Of Link HK comparisons for inserting into stage ~!' +  CHAR(13)


	RETURN @ReturnString
END



GO
