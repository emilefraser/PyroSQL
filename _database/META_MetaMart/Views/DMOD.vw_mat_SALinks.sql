SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_mat_SALinks]  AS

SELECT  link.SameAsLinkName AS [Same As Link Name]
		,link.SameAsLinkID AS [Same As Link ID]
		,link.HubID AS [Hub ID]
		,hub.HubName  AS [Hub Name]
		,f.SameAsLinkFieldID AS  [Same As Link Field ID]
		,f.MasterFieldID AS [Master Field ID]
		,mf.DataEntityName AS [Master Data Entity Name]
		,mf.FieldName AS [Master Field Name]
		,mf.DatabaseName AS [Master Database Name]
		,f.SlaveFieldID AS [Slave Field ID]
		,sf.DataEntityName  AS [Slave Data Entity Name]
		,sf.FieldName AS [Slave Field Name]
		,sf.DatabaseName AS [Slave Database Name]
	FROM [DMOD].SameAsLink link
	JOIN [DMOD].Hub hub
		ON hub.HubID = link.HubID
	LEFT JOIN [DMOD].SameAsLinkField f
		ON f.SameAsLinkID = link.SameAsLinkID
	LEFT JOIN [DC].vw_rpt_DatabaseFieldDetail mf
		ON	mf.FieldID = f.MasterFieldID
	LEFT JOIN [DC].vw_rpt_DatabaseFieldDetail sf
		ON	sf.FieldID = f.MasterFieldID

GO
