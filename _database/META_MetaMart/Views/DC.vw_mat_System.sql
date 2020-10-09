SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [DC].[vw_mat_System] AS
SELECT 
	s.SystemID AS [System ID],
	s.SystemName AS [System Name],
	s.SystemAbbreviation AS [System Abbreviation],
	s.[Description] As [Description],
	s.AccessInstructions AS [Access Instructions],
	s.UserID AS [User ID],
	s.IsBusinessApplication AS [Is Business Application],
	s.CreatedDT AS [Created Date],
	s.UpdatedDT AS [Updated Date],
	s.IsActive AS [Is Active],
	s.DataDomainID AS [Data Domain ID],
	dd.DataDomainCode AS [Data Domain Code]

	FROM [DC].[System] s

	LEFT JOIN [GOV].[DataDomain] dd
	ON
	s.DataDomainID = dd.DataDomainID

GO
