SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_rpt_Validate_LoadConfigTargetTableInVirtualDC] AS
SELECT	de.DataEntityID
		,de.DataEntityName
		,de.IsActive as ActiveDataEntity
		,d.DatabaseName
		,lc.TargetDataEntityID
		,lc.IsActive as ActiveLoadConfig
		--,CASE WHEN lc.TargetDataEntityID IS NULL	
		--	THEN 'No'
		--	ELSE 'Yes'
		--END AS HasLoadConfig
FROM	DMOD.DataEntity_VirtualDC de
	INNER JOIN DMOD.Schema_VirtualDC s ON de.SchemaID = s.SchemaID
	INNER JOIN DMOD.Database_VirtualDC d ON s.DatabaseID = d.DatabaseID
	LEFT JOIN	DMOD.LoadConfig lc ON de.DataEntityID = lc.TargetDataEntityID
WHERE	de.DataEntityName NOT LIKE '%Hist'
		AND  lc.TargetDataEntityID IS NULL

GO
