SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [DMOD].[vw_mat_PKFKLinks]  AS

SELECT link.PKFKLinkID AS [Link ID]
	  ,link.LinkName  AS [Link Name]
	  ,phub.HubID AS [Parent Hub ID]
	  ,phub.HubName AS [Parent Hub Name]
	  ,chub.HubID AS [Child Hub ID]
	  ,chub.HubName AS [Child Hub Name]
	  ,lf.PKFKLinkFieldID  AS [PKFKLink Field ID]
	  ,lf.PrimaryKeyFieldID AS [PK Field ID]
	  ,pkf.FieldName AS [PK Field Name]
	  ,pkf.DataEntityName AS [PK Data Entity Name]
	  ,lf.ForeignKeyFieldID  AS [FK Field ID]
	  ,fkf.FieldName AS [FK Field Name]
	  ,fkf.DataEntityName AS [FK Data Entity Name]
	  ,link.IsActive
	  ,lf.IsActive AS [IsActiveField]
	FROM [DMOD].[PKFKLink] link
	LEFT JOIN [DMOD].[Hub] phub
		ON phub.HubID = link.ParentHubID
	LEFT JOIN [DMOD].[Hub] chub
		ON chub.HubID = link.ChildHubID
	LEFT JOIN [DMOD].[PKFKLinkField] lf
		ON lf.PKFKLinkID = link.PKFKLinkID
	LEFT JOIN [DC].vw_rpt_DatabaseFieldDetail pkf
		ON	pkf.FieldID = lf.PrimaryKeyFieldID
	LEFT JOIN [DC].vw_rpt_DatabaseFieldDetail fkf
		ON	fkf.FieldID = lf.ForeignKeyFieldID

GO
