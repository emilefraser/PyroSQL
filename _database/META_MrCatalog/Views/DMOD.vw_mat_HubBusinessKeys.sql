SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [DMOD].[vw_mat_HubBusinessKeys] AS
SELECT  h.HubID AS [Hub ID]
		,h.HubName AS [Hub Name]
		,k.HubBusinessKeyID AS [Hub Business Key ID]
		,k.HubBKFieldID AS [Hub Business Key Field ID]
		,k.FieldSortOrder AS [Field Sort Order]
		,k.BKFriendlyName AS [Business Key Friendly Name]
		,k.IsActive AS [Is Active]


  FROM [DMOD].[Hub] h
  JOIN  [DMOD].[HubBusinessKey] k
		ON k.HubID = h.HubID
  --LEFT JOIN [DMOD].[HubBusinessKeyField] f
		--ON f.HubBusinessKeyID = k.HubBusinessKeyID


GO
