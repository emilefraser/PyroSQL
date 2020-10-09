SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [DMOD].[vw_OrphanHierarchicalLinks] AS
SELECT  l.*
	   ,h.HubID AS Hub_HubID

  FROM [DMOD].[HierarchicalLink] l
  LEFT JOIN [DMOD].[Hub] h
		ON h.HubID = l.HubID
  WHERE	isnull(h.HubID,'')=''

GO
