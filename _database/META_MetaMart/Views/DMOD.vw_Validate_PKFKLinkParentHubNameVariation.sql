SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_Validate_PKFKLinkParentHubNameVariation]
AS
SELECT LinkName AS LinkName
	 , hparent.HubName AS ParentHubName
	 , hchild.HubName AS ChildHubName
	 , l.ParentHubNameVariation
	 , CASE 
			WHEN l.ParentHubNameVariation = NULL 
				THEN 'THIS NEEDS A PARENTHUBNAMEVARIATION'
			WHEN ((REPLACE(l.LinkName,'LINK_','')) <> ( l.ParentHubNameVariation  + '_' + REPLACE(hchild.HubName,'HUB_','')))
				THEN 'THIS PARENTHUBNAMEVARIATION IS INVALID'		
			ELSE 'Correct'
	   END
	 --,  l.ParentHubNameVariation  + '_' + REPLACE(hparent.HubName,'HUB_','')
	   AS ParentHubNameVariationCheck
FROM DMOD.PKFKLink l
LEFT JOIN DMOD.Hub hparent ON
	l.ParentHubID = hparent.HubID
LEFT JOIN DMOD.Hub hchild ON
	l.ChildHubID = hchild.HubID
WHERE   l.IsActive = 1
	AND hchild.IsActive = 1
	AND hparent.IsActive = 1
	AND REPLACE(l.LinkName,'LINK_','') != REPLACE(hparent.HubName,'HUB_','') + REPLACE(hchild.HubName,'HUB','')

GO
