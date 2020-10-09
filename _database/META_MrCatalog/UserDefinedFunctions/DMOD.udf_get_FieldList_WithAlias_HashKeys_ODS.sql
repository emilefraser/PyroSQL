SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
-- ========================================================================================================================
-- Author:      Emile Fraser
-- Create Date: 6 June 2019
-- Description: Generate a Field list for a select statement from the ODS area table with a standard alias prefix
-- ========================================================================================================================

--!~ Hub & Link Hash Key Columns for ODS Select
				CONVERT	(VARCHAR(40),
					HASHBYTES	('SHA1',
							CONVERT	(VARCHAR(MAX),
									COALESCE(UPPER(LTRIM(RTRIM(StandardAlias2.[DPT_CODE]))),'')
									)
								)
							,2) AS [HK_DEPARTMENT]
				,CONVERT	(VARCHAR(40),
					HASHBYTES	('SHA1',
							CONVERT	(VARCHAR(MAX),
									COALESCE(UPPER(LTRIM(RTRIM(StandardAlias2.[DPT_CODE]))),'') + '|' +
									COALESCE(UPPER(LTRIM(RTRIM(StandardAlias.EMP_EMPNO))),'')
									)
								)
							,2) AS [LINK_DEPARTMENT_EMPLOYEE][HK_DEPARTMENT]
-- End of Hub & Link Hash Key Columns for ODS Select ~!
HOW?
	SELECT * FROM DMOD.vw_LoadConfig WHERE Target_DEName LIKE '%SalesInvoiceLine%'

	SELECT [DMOD].[udf_get_FieldList_WithAlias_HashKeys_ODS](10)
	SELECT [DMOD].[udf_get_FieldList_WithAlias_HashKeys_ODS](34)
		SELECT [DMOD].[udf_get_FieldList_WithAlias_HashKeys_ODS](1)

*/
CREATE FUNCTION [DMOD].[udf_get_FieldList_WithAlias_HashKeys_ODS](
    @LoadConfigID INT)
RETURNS VARCHAR(MAX)
AS
BEGIN

	-- :DEBUG:
		--	DECLARE @LoadConfigID INT = 14
			--SELECT * FROM DMOD.vw_LoadConfig WHERE LoadConfigID = @LoadConfigID
			--SELECT * FROM DC.System
	-- :DEBUG:
	DECLARE @Stage_DataEntityID INT
	DECLARE @ODS_DataEntityID INT
	,		@ODS_DataEntityName VARCHAR(250)
	,		@ODS_SystemID INT
	DECLARE @FieldList AS VARCHAR(MAX) = ''
	DECLARE @Seperator VARCHAR(1) = '.'
	DECLARE @HubID INT
	
	--SELECT * FROM DMOD.VW_LoadConfig WHERE LoadConfigID = 12
	SET @ODS_DataEntityID = (SELECT SourceDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)
	SET @Stage_DataEntityID = (SELECT TargetDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)

	-- Get the Hub of the Source of the Link (WHERE Link Originates from)
	SET @HubID =
	(
		SELECT DISTINCT
			h.HubID
		FROM 
				DMOD.Hub AS h
		INNER JOIN 
			DMOD.HubBusinessKey AS hbk
			ON hbk.HubID = h.HubID
		INNER JOIN 
			DMOD.HubBusinessKeyField AS hbkf
			ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
		INNER JOIN 
			DC.[Field] AS f
			ON f.FieldID = hbkf.FieldID
		WHERE
			f.DataEntityID = @ODS_DataEntityID
		and
			ISNULL(h.IsActive, 0) = 1
		AND
			ISNULL(hbk.IsActive, 0) = 1
		AND
			ISNULL(hbkf.IsActive, 0) = 1
		AND
			ISNULL(hbkf.IsBaseEntityField, 0) = 1
	)
	
	-- :DEBUG:
		--	SELECT @HubID
		--	SELECT HubName FROM DMOD.Hub WHERE HubID = @HubID
	-- :DEBUG:
	DECLARE @LinkTableSort TABLE (FieldID VARCHAR(255), FieldName VARCHAR(250), FieldSortOrder INT)
	INSERT INTO @LinkTableSort(FieldID, FieldName, FieldSortOrder)
	SELECT f.FieldID, f.FieldName, f.FieldSortOrder
	FROM DC.Field AS f
	WHERE f.dataentityid = @Stage_DataEntityID
	order by f.fieldSortorder

	SET @ODS_SystemID = (SELECT DC.udf_GetSourceSystemIDForDataEntityID(@ODS_DataEntityID))
	SET @ODS_DataEntityName = (SELECT DataEntityName FROM DC.DataEntity WHERE DataEntityID = @ODS_DataEntityID)


	DECLARE @LinkTable TABLE (ChildHubID INT, ChildHubName VARCHAR(255), PKFKLinkID INT, PKFKLinkName VARCHAR(255),
									ParentHubID INT, ParentHubName VARCHAR(255), FieldSortOrder INT, SortOrder INT, LinkIncrementer INT, TableAliasNumber INT, 
										/*HubBusinessKeyFieldID INT,*/ FieldID INT, FieldName VARCHAR(255), SystemID INT, HK_Name VARCHAR(255))


	INSERT INTO @LinkTable  (ChildHubID, ChildHubName , PKFKLinkID , PKFKLinkName ,
									ParentHubID,  ParentHubName, FieldSortOrder, SortOrder, LinkIncrementer, TableAliasNumber , 
											/* HubBusinessKeyFieldID,*/ FieldID , FieldName, SystemID, HK_Name)
	SELECT DISTINCT
				hc.HubID AS ChildHubID
			,	hc.HubName AS ChildHubName
			,	pkfk.PKFKLinkID
			,	pkfk.LinkName
			,	hp.HubID AS ParentHubID
			,	hp.HubName AS ParentHubName
			,	bk.FieldSortOrder
			,	RANK() OVER (ORDER BY bk.FieldSortOrder ASC) AS SortOrder
			,	DENSE_RANK() OVER(ORDER BY ss.FieldSortOrder ASC) AS LinkIncrementer
			,	DENSE_RANK() OVER(ORDER BY ss.FieldSortOrder ASC)+1 AS TableAliasNumber
			--,	bkf.HubBusinessKeyFieldID
			,	bkf.FieldID
			,	f.FieldName
			,	DC.udf_GetSourceSystemIDForDataEntityID(f.DataEntityID) AS SystemID
			,	'HK_' + ISNULL(pkfk.ParentHubNameVariation,  REPLACE(REPLACE(pkfk.LinkName, REPLACE(hc.HubName, 'HUB', ''), ''), 'LINK_', '')) AS HK_Name
			FROM 
				DMOD.Hub AS hc
			INNER JOIN 
				DMOD.PKFKLink AS pkfk
				ON pkfk.ChildHubID = hc.HubID	--FROM THIS POINT WE USE THE PARENT HUBS to determine their BKs for the HashKeys
			INNER JOIN 
				DMOD.PKFKLinkField AS pkfkf
				ON pkfkf.PKFKLinkID	= pkfk.PKFKLinkID
			INNER JOIN 
				DC.Field AS sf
				ON sf.FieldID = pkfkf.PrimaryKeyFieldID
			INNER JOIN 
				DMOD.Hub AS hp
				ON hp.HubID = pkfk.ParentHubID
			INNER JOIN 
				DMOD.HubBusinessKey AS bk
				ON bk.HubID = hp.HubID
			INNER JOIN 
				DMOD.HubBusinessKeyField AS bkf
				ON bkf.HubBusinessKeyID = bk.HubBusinessKeyID
			INNER JOIN 
				DC.[Field] AS f
				ON f.FieldID = bkf.FieldID
			INNER JOIN
				@LinkTableSort AS ss
			ON 
				REPLACE(pkfk.LinkName, 'LINK_', 'LINKHK_') = ss.FieldName
			WHERE 
				hc.HubID = @HubID
			AND
				ISNULL(hc.IsActive, 0) = 1
			AND
				ISNULL(hp.IsActive, 0) = 1
			AND
				ISNULL(pkfk.IsActive, 0) = 1
			AND
				ISNULL(pkfkf.IsActive, 0) = 1
			AND
				ISNULL(bk.IsActive, 0) = 1
			AND
				ISNULL(bkf.IsActive, 0) = 1
			AND
				ISNULL(f.IsActive, 0) = 1
			AND 
				DC.udf_GetSourceSystemIDForDataEntityID(sf.DataEntityID) = @ODS_SystemID -- Keep contained to current ODS SystemID
			AND 
				DC.udf_GetSourceSystemIDForDataEntityID(f.DataEntityID) = @ODS_SystemID -- Keep contained to current ODS SystemID


	-- :DEBUG:
		--	SELECT * FROM @LinkTable
		--	SELECT @ODS_SystemID
	--		DECLARE @HubID INT = (SELECT DISTINCT ChildHubID FROM @LinkTable)
	-- :DEBUG:

	DECLARE @BKTable TABLE (HubID INT, HubName VARCHAR(255), FieldSortOrder INT, FieldID INT, FieldName VARCHAR(255), SystemID INT)
	INSERT INTO @BKTable  
	(
			HubID 
		,	HubName 
		,	FieldSortOrder 
		,	FieldID 
		,	FieldName
		,	SystemID  
	)
	SELECT 
		h.HubID
	,	h.HubName
	,	RANK() OVER (ORDER BY hbk.FieldSortOrder ASC) AS FieldSortOrder
	,	hbkf.FieldID
	,	f.FieldName
	,	DC.udf_GetSourceSystemIDForDataEntityID(f.DataEntityID) AS SystemID_pk
	FROM 
		DMOD.Hub AS h
	INNER JOIN 
		DMOD.HubBusinessKey AS hbk
		ON hbk.HubID = h.HubID
	INNER JOIN 
		DMOD.HubBusinessKeyField AS hbkf
		ON hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
	INNER JOIN 
		DC.[Field] AS f
		ON f.FieldID = hbkf.FieldID
	WHERE 
		h.HubID = @HubID
	AND
		ISNULL(h.IsActive, 0) = 1
	AND
		ISNULL(hbk.IsActive, 0) = 1
	AND
		ISNULL(hbkf.IsActive, 0) = 1
	AND	
		ISNULL(f.IsActive, 0) = 1
	AND	
		DC.udf_GetSourceSystemIDForDataEntityID(f.DataEntityID) = @ODS_SystemID -- Keep contained to current ODS SystemID

	-- :DEBUG:
		--SELECT * FROM @BKTable
		--SELECT @Source_SystemID
	-- :DEBUG:

	-- Start Generation of the Return Statement
	SELECT @FieldList = @FieldList + '--!~ Hub & Link Hash Key Columns for ODS Select' + CHAR(13)

	-- :TODELETE:
	--		DECLARE @totalloops INT = (SELECT MAX(SortOrder) FROM @LinkTable) 
	-- :TODELETE:

	DECLARE @totalloops INT = (SELECT MAX(LinkIncrementer) FROM @LinkTable) 

	DECLARE @currentloop INT = 1
	IF(@totalloops <> 0)
	BEGIN
		WHILE @currentloop <= @totalloops
		BEGIN

			-- Non-Recursive by SELECT, but Recursive by Loop Portion
			SELECT 
				@FieldList = @FieldList + ',' + ' CONVERT(VARCHAR(40),' + CHAR(13)
				+ REPLICATE(CHAR(9),5) + ' HASHBYTES (''SHA1'',' + CHAR(13)
						
			-- Recursive by SELECT AND Recursive by Loop Portion
			SELECT 
				@FieldList = @FieldList + REPLICATE(CHAR(9),6) + '  CONVERT	(VARCHAR(MAX),' + CHAR(13)
				+ REPLICATE(CHAR(9),7) + '  COALESCE(UPPER(LTRIM(RTRIM(' + QUOTENAME('StandardAlias' + CONVERT(VARCHAR(4), h.[TableAliasNumber])) + @Seperator + QUOTENAME(h.[FieldName]) + '))),''NA''))  + ''|'' +' + CHAR(13)
			FROM 
				@LinkTable AS h
			WHERE 
				h.LinkIncrementer = @currentloop
			ORDER BY 
				h.FieldSortOrder ASC

			-- Remove training pipe due to unknown reccursion count by SELECT 
			SET @FieldList = LEFT(@FieldList, LEN(@FieldList) - 9) + CHAR(13)
				
			-- Each Field IN BK has a HK assigned to it, we only need 1 per group
			SELECT TOP 1 
				@FieldList = @FieldList + REPLICATE(CHAR(9),6) + ' )' + CHAR(13)
				+ REPLICATE(CHAR(9),5) + ' ,2) AS ' + QUOTENAME(h.HK_Name) + CHAR(13)
			FROM 
				@LinkTable AS h
			WHERE 
				h.LinkIncrementer = @currentloop

			-- Non-Recursive by SELECT, but Recursive by Loop Portion
			SELECT 
				@FieldList = @FieldList + ',' +  ' CONVERT(VARCHAR(40),' + CHAR(13)
				+ REPLICATE(CHAR(9),5) + ' HASHBYTES (''SHA1'',' + CHAR(13)

			-- Recursive by SELECT AND Recursive by Loop Portion
			SELECT 
				@FieldList = @FieldList + REPLICATE(CHAR(9),6) + '  CONVERT	(VARCHAR(MAX),' + CHAR(13)
				+ REPLICATE(CHAR(9),7) + '  COALESCE(UPPER(LTRIM(RTRIM(' + QUOTENAME('StandardAlias' + CONVERT(VARCHAR(4), h.[TableAliasNumber])) + @Seperator + QUOTENAME(h.[FieldName]) + '))),''NA'')) + ''|'' +' + CHAR(13)
			FROM 
				@LinkTable AS h
			WHERE 
				h.LinkIncrementer = @currentloop
			ORDER BY 
				h.FieldSortOrder

			SELECT 
				@FieldList = @FieldList + REPLICATE(CHAR(9),6) + '  CONVERT	(VARCHAR(MAX),' + CHAR(13)
				+ REPLICATE(CHAR(9),7) + '  COALESCE(UPPER(LTRIM(RTRIM(' + QUOTENAME('StandardAlias' + CONVERT(VARCHAR(4), 1)) + @Seperator + QUOTENAME(b.[FieldName]) + '))),'''')) + ''|'' +' + CHAR(13)
			FROM 
				@BKTable AS b
			--ORDER BY 
			--	b.SortOrder

			SET @FieldList = LEFT(@FieldList, LEN(@FieldList) - 9)
			
			SELECT TOP 1 
				@FieldList = @FieldList  + CHAR(13)	 
				+ REPLICATE(CHAR(9),6) + ' )' + CHAR(13)
				+ REPLICATE(CHAR(9),5) + ' ,2) AS ' + QUOTENAME(REPLACE(h.PKFKLinkName, 'LINK_','LINKHK_')) + CHAR(13)
			FROM 
				@LinkTable AS h
			WHERE 
				h.LinkIncrementer = @currentloop

			
			SET @currentloop = @currentloop + 1 

		END

	END

	SELECT @FieldList = @FieldList + '-- End of Hub & Link Hash Key Columns for ODS Select ~!' + CHAR(13)

	-- :DEBUG:
			--PRINT @FieldList
	-- :DEBUG:

	
	RETURN @FieldList
END

GO
