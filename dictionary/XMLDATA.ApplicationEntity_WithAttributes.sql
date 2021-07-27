SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   VIEW [XMLDATA].[ApplicationEntity_WithAttributes]
AS
SELECT
	appmod.[Prefix] AS ApplicationPrefix
,	appmod.[ApplicationName]
,	appmod.[ApplicationVersion]
,	appview.[RotoID] AS ViewID
,	appview.[TableCodes] AS TableCode
,	appview.[Title] AS ViewTitle
,	appview.[Dll]
,	appviewattrib.[AttributeKey] AS [ViewAttributeKey]
,	appviewattrib.[AttributeValue] AS [ViewAttributeValue]
,	appviewattrib.[AttributeDescription] AS [ViewAttributeDescription]
,	apptable.[TableID]
,	apptable.[Title] AS TableTitle
,	apptableattrib.[AttributeKey] AS [TableAttributeKey]
,	apptableattrib.[AttributeValue] AS [TableAttributeValue]
,	apptableattrib.[AttributeDescription] AS [TableAttributeDescription]
,	appobject.ObjectCode
,	appobject.Protocol
,	appobjectattrib.AttributeKey
,	appobjectattrib.AttributeValue
,	appobjectattrib.AttributeDescription
FROM
	[XMLDATA].[ApplicationObjectModel] AS appmod
LEFT JOIN
	[XMLDATA].[ApplicationView] AS appview
	ON appview.[ApplicationID] = appmod.[ApplicationID]
LEFT JOIN
	[XMLDATA].[ApplicationTable] AS apptable
	ON apptable.[ApplicationID] = appmod.[ApplicationID]
	AND apptable.[TableID] = appview.TableCodes
LEFT JOIN 
	[XMLDATA].[ApplicationViewAttribute] AS appviewattrib
	ON appviewattrib.ApplicationViewID = appview.ApplicationViewID
LEFT JOIN 
	[XMLDATA].[ApplicationTableAttribute] AS apptableattrib
	ON appTableattrib.ApplicationTableID = appTable.ApplicationTableID
LEFT JOIN 
	[XMLDATA].[ApplicationobjectAttribute] AS appobjectattrib
	ON appobjectattrib.AttributeValue = appview.[RotoID]
LEFT JOIN 
	[XMLDATA].[ApplicationObject] AS appobject
	ON appobject.ApplicationObjectID = appobjectattrib.ApplicationObjectID

GO
