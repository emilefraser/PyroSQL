SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DC].[vw_mat_System] AS
SELECT 
	SystemID AS [System ID],
	SystemName AS [System Name],
	SystemAbbreviation AS [System Abbreviation],
	[Description] As [Description],
	AccessInstructions AS [Access Instructions],
	UserID AS [User ID],
	IsBusinessApplication AS [Is Business Application],
	CreatedDT AS [Created Date],
	UpdatedDT AS [Updated Date],
	IsActive AS [Is Active],
	DataDomainID AS [Data Domain ID]

	FROM [DC].[System]

GO
