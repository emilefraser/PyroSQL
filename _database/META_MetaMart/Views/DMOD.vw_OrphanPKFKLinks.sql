SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [DMOD].[vw_OrphanPKFKLinks] AS
SELECT  l.PKFKLinkID 
	  ,l.LinkName 
	  ,ph.HubID AS ParentHub_HubID
	  ,chh.HubID AS ChildHub_HubID
  FROM [DMOD].[PKFKLink] l
  LEFT JOIN [DMOD].[Hub] ph
		ON ph.HubID = l.ParentHubID
  LEFT JOIN [DMOD].[Hub] chh
		ON chh.HubID = l.ChildHubID
WHERE	isnull(ph.HubID,'')=''
		OR isnull(chh.HubID,'')=''

GO
