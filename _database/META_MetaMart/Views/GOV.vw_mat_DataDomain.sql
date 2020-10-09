SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [GOV].[vw_mat_DataDomain] AS
SELECT 
DataDomainCode AS [Data Domain Code],
DataDomainDescription AS [Data Domain Description],
DataDomainID AS [Data Domain ID],
DataDomainParentID AS [Data Domain Parent ID],
CreatedDT AS [Created Date],
UpdatedDT AS [Updated Date],
IsActive AS [Is Active]
FROM [GOV].[DataDomain]

GO
