/****** Script for SelectTopNRows command from SSMS  ******/
SELECT hub.HK_EVENTTYPE
		,hub.EventTypeCodeID
		,hub.EventTypeMessage
		,sat.ET_NAME
		,sat.ET_DESCRIPTION

		,ods.ET_CODEID
		,ods.ET_DISPMSG
		,ods.ET_NAME
		,ods.ET_DESCRIPTION
  FROM [DataVault].[RAW].[HUB_EventType] hub
  JOIN [DataVault].[RAW].[SAT_EventType_XT_LVD] sat
	ON hub.HK_EVENTTYPE = sat.HK_EventType
		AND sat.LoadEndDT IS NULL 
FULL OUTER JOIN ODS_XT900.dbo.eventtype ods
	ON ods.ET_CODEID = hub.EventTypeCodeID
	WHERE hub.EventTypeCodeID = 107 

	WHERE hub.EventTypeMessage <> ods.ET_DISPMSG
			OR sat.ET_NAME <> ods.ET_NAME
			OR sat.ET_DESCRIPTION <> ods.ET_DESCRIPTION


			SELECT * 
			FROM [DataVault].[RAW].[HUB_EventType] hub
  JOIN [DataVault].[RAW].[SAT_EventType_XT_LVD] sat
	ON hub.HK_EVENTTYPE = sat.HK_EventType
		AND sat.LoadEndDT IS NULL 
		WHERE hub.EventTypeCodeID = 107