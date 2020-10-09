SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [dbo].[vw_DimBusinessUnit] AS

SELECT 
	--KEYS
	hub.HK_BUSINESSUNIT AS [BusinessUnitKey]

	--ATTRIBUTES
	,hub.BusinessUnitName
	,hub.Subsidiary

FROM
	--BluESP HUB
	[DEV_DataVault].[raw].[HUB_BusinessUnit] hub

	--LINK to Subsidiary ----double check logic: link to subsidiary
	--LEFT JOIN [DEV_DataVault].[raw].[LINK_Subsidiary_BusinessUnit] sub_bu
	--	ON sub_bu.HK_BusinessUnit = hub.HK_BUSINESSUNIT
	   

GO
