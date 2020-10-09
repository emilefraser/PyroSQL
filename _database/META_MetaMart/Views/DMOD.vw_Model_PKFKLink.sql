SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [DMOD].[vw_Model_PKFKLink] AS
SELECT
	pkfk.PKFKLinkID
,	pkfk.LinkName
,	pkfk.ParentHubNameVariation
,	pkfk.ParentHubID
,	pkfk.ChildHubID
,	pkfk.IsActive AS IsActive_PKFKLink
,	pkfkf.PKFKLinkFieldID
,	pkfkf.PrimaryKeyFieldID
,	pkfkf.ForeignKeyFieldID
,	pkfkf.IsActive AS IsActive_PKFKLinkField
,	ph.HubID AS ParentHub_HubID
,	ph.HubName AS ParentHub_HubName
,	ph.HubDataEntityID AS ParentHub_HubDataEntityID
,	ph.EnsembleStatus AS ParentHub_EnsambleStatus
,	ph.IsActive AS ParentHub_IsActive 
,	ch.HubID AS ChildHub_HubID
,	ch.HubName AS ChildHub_HubName
,	ch.HubDataEntityID AS ChildHub_HubDataEntityID
,	ch.EnsembleStatus AS ChildHub_EnsambleStatus
,	ch.IsActive AS ChildHub_IsActive 
FROM
	DMOD.PKFKLink AS pkfk
INNER JOIN 
	DMOD.PKFKLinkField AS pkfkf
	ON pkfkf.PKFKLinkID = pkfk.PKFKLinkID
LEFT JOIN 
	DMOD.Hub AS ph
	ON ph.HubID = pkfk.ParentHubID
LEFT JOIN 
	DMOD.Hub AS ch
	ON ch.HubID = pkfk.ChildHubID




GO
