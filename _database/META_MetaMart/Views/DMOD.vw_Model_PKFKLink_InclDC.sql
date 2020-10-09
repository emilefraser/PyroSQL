SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_Model_PKFKLink_InclDC] AS
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
,	pf.FieldName AS Parent_FieldName
,	pf.IsActive AS Parent_IsActive_Field
,	pde.DataEntityID AS Parent_DataEntityID
,	pde.IsActive AS Parent_IsActive_DataEntity
,	ps.SchemaID AS Parent_SchemaID
,	ps.SchemaName AS Parent_SchemaName
,	ps.IsActive AS Parent_IsActive_Schema
,	pdb.DatabaseID AS Parent_DatabaseID
,	pdb.DatabaseName AS Parent_DatabaseName
,	pdb.IsActive AS Parent_IsActive_Database
,	ch.HubID AS ChildHub_HubID
,	ch.HubName AS ChildHub_HubName
,	ch.HubDataEntityID AS ChildHub_HubDataEntityID
,	ch.EnsembleStatus AS ChildHub_EnsambleStatus
,	ch.IsActive AS ChildHub_IsActive 
,	cf.FieldName AS Child_FieldName
,	cf.IsActive AS Child_IsActive_Field
,	cde.DataEntityID AS Child_DataEntityID
,	cde.IsActive AS Child_IsActive_DataEntity
,	cs.SchemaID AS Child_SchemaID
,	cs.SchemaName AS Child_SchemaName
,	cs.IsActive AS Child_IsActive_Schema
,	cdb.DatabaseID AS Child_DatabaseID
,	cdb.DatabaseName AS Child_DatabaseName
,	cdb.IsActive AS Child_IsActive_Database
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
INNER JOIN 
	DC.Field AS pf
ON 
	pf.FieldID = pkfkf.PrimaryKeyFieldID
INNER JOIN 
	DC.DataEntity AS pde
ON 
	pde.DataEntityID = pf.DataEntityID
INNER JOIN 
	DC.[Schema] AS ps
ON	
	ps.SchemaID = pde.SchemaID
INNER JOIN
	DC.[Database] AS pdb
ON 
	pdb.DatabaseID = ps.DatabaseID
INNER JOIN 
	DC.Field AS cf
ON 
	cf.FieldID = pkfkf.ForeignKeyFieldID
INNER JOIN 
	DC.DataEntity AS cde
ON 
	cde.DataEntityID = cf.DataEntityID
INNER JOIN 
	DC.[Schema] AS cs
ON	
	cs.SchemaID = cde.SchemaID
INNER JOIN
	DC.[Database] AS cdb
ON 
	cdb.DatabaseID = cs.DatabaseID


GO
