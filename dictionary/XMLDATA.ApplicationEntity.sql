SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   VIEW [XMLDATA].ApplicationEntity
AS
SELECT
	appmod.[Prefix]
,	appmod.[ApplicationName]
,	appmod.[ApplicationVersion]
,	appview.[RotoID]
,	appview.[TableCodes]
,	appview.[Title] AS View_Title
,	appview.[Dll]
,	apptable.[TableID]
,	apptable.[Title] AS Table_Title
FROM
	[XMLDATA].[ApplicationObjectModel] AS appmod
LEFT JOIN
	[XMLDATA].[ApplicationView] AS appview
	ON appview.[ApplicationID] = appmod.[ApplicationID]
LEFT JOIN
	[XMLDATA].[ApplicationTable] AS apptable
	ON apptable.[ApplicationID] = appmod.[ApplicationID]
	AND apptable.[TableID] = appview.TableCodes
GO
