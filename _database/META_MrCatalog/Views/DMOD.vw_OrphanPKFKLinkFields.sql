SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [DMOD].[vw_OrphanPKFKLinkFields] AS
SELECT  lf.*
	  ,l.PKFKLinkID AS PKFKLink_PKFKLinkID
	  ,l.LinkName AS PKFKLink_LinkName
	  ,ph.HubID AS ParentHub_HubID
	  ,chh.HubID AS ChildHub_HubID
  FROM [DMOD].[PKFKLinkField] lf
  LEFT JOIN [DMOD].[PKFKLink] l
		ON l.PKFKLinkID = lf.PKFKLinkID
  LEFT JOIN [DMOD].[Hub] ph
		ON ph.HubID = l.ParentHubID
  LEFT JOIN [DMOD].[Hub] chh
		ON chh.HubID = l.ChildHubID
WHERE	isnull(l.PKFKLinkID,'')=''
		OR isnull(ph.HubID,'')=''
		OR isnull(chh.HubID,'')=''



GO
