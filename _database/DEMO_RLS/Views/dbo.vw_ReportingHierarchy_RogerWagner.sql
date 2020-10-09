SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW dbo.vw_ReportingHierarchy_RogerWagner 
AS

SELECT 
	* 
FROM
	[oilgasrlsdemo2016].[dbo].[vw_ReportingHierarhy]
WHERE	
	NAME_LINEAGE LIKE 'Roger Wagner%'
GO
