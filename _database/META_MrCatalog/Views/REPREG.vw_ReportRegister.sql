SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [REPREG].[vw_ReportRegister] AS
SELECT	R.ReportID
	,CASE WHEN RP.ReportPackTitle = R.ReportName THEN RP.ReportPackTitle ELSE RP.ReportPackTitle + ' > '  + R.[ReportName] END as ReportName
	, R.[Description] as ReportDescription
	,RT.ReportTypeDescription
	,RP.ReportPackTitle, RP.ReportPackDescription
	,ISNULL(RS.ErrorParagraph,RST.DefaultErrorParagraph) as ErrorParagraph
	,RST.ReportStatusIndicator, RST.ReportStatusTypeName
	,RTN.ReportTechnologyName, RTN.IsReportPackCapable
	,RE.ReportElementName, RE.ReportElementDescription
	--,RES.ReportStatusTypeID
	,RST1.ReportStatusIndicator AS ReportElementStatusIndicator
FROM	[REPREG].[Report] R
	LEFT JOIN	[REPREG].[ReportType] RT ON R.ReportType = RT.ReportTypeID
	LEFT JOIN	[REPREG].[ReportPack] RP ON R.ReportPackID = RP.ReportPackID
	LEFT JOIN	[REPREG].[ReportStatus] RS ON R.ReportID = RS.ReportID
	LEFT JOIN	[REPREG].[ReportStatusType] RST ON RS.ReportStatusTypeID = RST.ReportStatusTypeID
	LEFT JOIN	[REPREG].[ReportTechnology] RTN ON R.ReportTechnologyID = RTN.ReportTechnologyID
	LEFT JOIN	[REPREG].[ReportElement] RE ON RE.ReportID = R.ReportID
	LEFT JOIN	[REPREG].[ReportElementStatus] RES ON RE.ReportElementID = RES.ReportElementID
	LEFT JOIN	[REPREG].[ReportStatusType] RST1 ON RES.ReportStatusTypeID = RST1.ReportStatusTypeID

GO
