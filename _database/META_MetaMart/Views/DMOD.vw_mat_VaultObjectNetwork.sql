SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON







--/****** Object:  View [DMOD].[vw_mat_BaseEntityFields]    Script Date: 2019/07/03 16:57:02 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--Colours:
--Hub:			Light blue	#00ccff
--Link:			Green		#00ff99
--Sat:			Yellow		#ffff99
--Data Entity:	Orange		#ff9900

CREATE VIEW [DMOD].[vw_mat_VaultObjectNetwork] AS

--Entities
SELECT  entities.[Hub Name] AS SourceObject, 
		entities.[Database Name] + '.' + entities.[Schema Name] + '.' + entities.[Data Entity Name]  as TargetObject, 
		'Hub' AS SourceObjectType, 		
		'#00ccff' AS SourceColour,
		'#ff9900' AS TargetColour,
		'Data Entity' AS TargetObjectType,	
		6 AS DataDomain,
		35 AS SourceSize,
		35 AS TargetObjectSize,
		entities.[Database Name],
		entities.[Schema Name],
		entities.[System Name]
	FROM [DMOD].[vw_mat_HubBaseEntities] entities  --34


UNION

--Links
	SELECT  [HubName]  AS SourceObject, 
			[link].LinkName AS TargetObject, 
			'Hub' AS SourceObjectType, 
			'#00ccff' AS SourceColour,
			'#00ff99' AS TargetColour,
			'Link' AS TargetObjectType,	
			6 AS DataDomain	,
			35 AS SourceSize,
			15 AS TargetObjectSize,
			'',
			'',
			''
		FROM [DMOD].[PKFKLink] link
		INNER JOIN [DMOD].[Hub] phub
			ON phub.HubID = link.ParentHubID
		WHERE phub.IsActive = 1
			AND link.IsActive = 1

--Hierarchical Links
UNION
	SELECT  [HubName]  AS SourceObject, 
			[link].HierarchicalLinkName AS TargetObject, 
			'Hub' AS SourceObjectType, 
			'#00ccff' AS SourceColour,
			'#00ff99' AS TargetColour,
			'HierarchicalLink' AS TargetObjectType,	
			6 AS DataDomain	,
			35 AS SourceSize,
			15 AS TargetObjectSize,
			'',
			'',
			''
		FROM [DMOD].[HierarchicalLink] link
		LEFT JOIN [DMOD].[Hub] hub
			ON hub.HubID = link.HubID
		WHERE hub.IsActive = 1
			AND hub.IsActive = 1

UNION		
	SELECT  [HubName]  AS SourceObject, 
			[link2].LinkName AS TargetObject,  
			'Hub' AS SourceObjectType, 
			'#00ccff' AS SourceColour,
			'#00ff99' AS TargetColour,
			'Link' AS TargetObjectType,	
			6 AS DataDomain,
			35 AS SourceSize,
			15 AS TargetObjectSize,
			'',
			'',
			''
		FROM [DMOD].[PKFKLink] link2
		LEFT JOIN [DMOD].[Hub] chub
			ON chub.HubID = link2.ChildHubID
		WHERE chub.IsActive = 1
			AND link2.IsActive = 1



UNION	

--Satellites
	SELECT  [HubName]  AS SourceObject, 
			sat.SatelliteName AS TargetObject,  
			'Hub' AS SourceObjectType, 
			'#00ccff' AS SourceColour,
			'#ffff99' AS TargetColour,
			'Satellite' AS TargetObjectType,	
			6 AS DataDomain,
			35 AS SourceSize,
			15 AS TargetObjectSize,
			'',
			'',
			''
		FROM [DMOD].[Satellite] sat
		LEFT JOIN [DMOD].[Hub] hub
			ON  hub.HubID = sat.HubID
		WHERE hub.IsActive = 1


UNION

--Many to Many Links	
	SELECT  [HubName]  AS SourceObject, 
			[link].[Link Name] AS TargetObject,  
			'Hub' AS SourceObjectType, 
			'#00ccff' AS SourceColour,
			'#00ff99' AS TargetColour,
			'Many To Many Link' AS TargetObjectType,	
			6 AS DataDomain,
			35 AS SourceSize,
			15 AS TargetObjectSize,
			'',
			'',
			''
		FROM [DMOD].[vw_mat_ManyToManyLinkFields] link
		LEFT JOIN [DMOD].[Hub] chub
			ON chub.HubID = link.[Hub ID]
		WHERE chub.IsActive = 1


UNION
	SELECT  [HubName]  AS SourceObject, 
			[link].LinkName AS TargetObject,  
			'Hub' AS SourceObjectType, 
			'#00ccff' AS SourceColour,
			'#00ff99' AS TargetColour,
			'Many To Many Link' AS TargetObjectType,	
			6 AS DataDomain,
			35 AS SourceSize,
			15 AS TargetObjectSize,
			'',
			'',
			''
		FROM [DMOD].[ManyToManyLink] link
		LEFT JOIN [DMOD].[Hub] hub
			ON hub.HubID = link.HubID
		WHERE hub.IsActive = 1



GO
