SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW BALANCE.GLAccount
AS

SELECT 
	'GLAccount' AS Perspective
,	vgl.Count_GLAccount_view
,	dgl.Count_GLAccount_dataset

FROM (

	SELECT 
		'GLAccount' AS Perspective
	,	COUNT(DISTINCT AccountID) AS Count_GLAccount_view 
	FROM 
		dbo.vw_DimGLAccount
) AS vgl 
LEFT JOIN (
	
	SELECT 
		'GLAccount' AS Perspective
	,	COUNT(DISTINCT AccountID) AS Count_GLAccount_dataset
	FROM 
		dbo.vw_dataset_GLAccount

) AS dgl
ON vgl.Perspective = dgl.Perspective

GO
