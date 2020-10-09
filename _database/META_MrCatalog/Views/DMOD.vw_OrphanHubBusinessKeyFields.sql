SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [DMOD].[vw_OrphanHubBusinessKeyFields] AS
SELECT  bkf.[HubBusinessKeyID]
      ,[FieldID]
      ,[IsBaseEntityField]
	  ,bk.HubBusinessKeyID AS HubBusinessKey_HubBusinessKeyID
	  ,bk.BKFriendlyName AS HubBusinessKey_BKFriendlyName
	  ,h.HubID AS Hub_HubID
  FROM [DMOD].[HubBusinessKeyField] bkf
  LEFT JOIN [DMOD].[HubBusinessKey] bk
		ON bk.HubBusinessKeyID = bkf.HubBusinessKeyID
  LEFT JOIN [DMOD].[Hub] h
		ON h.HubID = bk.HubID

WHERE	isnull(bk.HubBusinessKeyID,'')=''
		OR isnull(h.HubID,'')=''

--SELECT * 
--DELETE
--FROM [DMOD].[HubBusinessKeyField] WHERE HubBusinessKeyID IN (28,29)


--SELECT * 
----DELETE
--FROM [DMOD].[HubBusinessKey] WHERE HubBusinessKeyID IN (28,29)


GO
