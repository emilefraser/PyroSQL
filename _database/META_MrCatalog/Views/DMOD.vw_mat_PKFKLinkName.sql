SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_mat_PKFKLinkName]  AS

SELECT link.PKFKLinkID AS [Link ID]
	  ,link.LinkName  AS [Link Name]
	  ,link.ParentHubNameVariation AS [Parent Hub Name Variation]
	  ,phub.HubID AS [Parent Hub ID]
	  ,phub.HubName AS [Parent Hub Name]
	  ,chub.HubID AS [Child Hub ID]
	  ,chub.HubName AS [Child Hub Name]
	  ,link.IsActive
	FROM [DMOD].[PKFKLink] link
	LEFT JOIN [DMOD].[Hub] phub
		ON phub.HubID = link.ParentHubID
	LEFT JOIN [DMOD].[Hub] chub
		ON chub.HubID = link.ChildHubID

GO
