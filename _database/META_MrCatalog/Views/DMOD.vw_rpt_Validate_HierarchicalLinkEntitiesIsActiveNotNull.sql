SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_rpt_Validate_HierarchicalLinkEntitiesIsActiveNotNull] AS

SELECT
	  *
FROM
	DMOD.HierarchicalLink l
WHERE
	l.IsActive Is Null




--	OR (lf.PKFKLinkID Is Not Null AND lf.IsActive Is Null)

GO
