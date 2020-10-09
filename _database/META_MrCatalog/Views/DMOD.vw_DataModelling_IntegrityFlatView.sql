SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_DataModelling_IntegrityFlatView]
AS
SELECT DISTINCT
	   h.hubid AS MasterHubID
	  ,h.HubName AS MasterHubName
	  ,h.HubDataEntityID AS MasterHubDataEntityID
	  ,h.CreatedDT AS MasterHubCreatedDT
	  ,h.IsActive AS IsMasterHubActive
	  ,hbk.HubBusinessKeyID AS MasterHubBKID
	  ,hbk.HubBKFieldID AS MasterHubBKFieldID
	  ,hbk.IsActive AS MasterHubBKIsActive
	  ,hbk.CreatedDT AS MasterHubBKCreatedDT
	  ,bkfield.SystemID
	  ,bksys.SystemName
	  ,bkfield.DatabaseName
	  ,bkfield.DataEntityID
	  ,bkfield.DataEntityName
	  ,hbkf.FieldID AS MasterHubSourceBKFieldID
	  ,hbk.BKFriendlyName AS MasterHubBKFriendlyName
	  ,sourcebkfield.FieldName AS MasterHubSourceBKFieldName
	  ,hbkf.CreatedDT AS MasterHubSourceBKFieldCreatedDT
	  ,hbkf.Isactive AS MasterHubSourceBKFieldIsActive
	  ,pkfklink.LinkName AS PKFKLinkName
	  ,pkfklink.ParentHubNameVariation AS ParentHubNameVariation
	  ,pkfklink.ChildHubID AS PKFKLinkChildHubID
	  ,pkfkchildhub.HubName AS PKFKLinkChildHubName
	  ,pkfkchildhub.HubDataEntityID AS PKFKLinkChildDataEntityID
	  ,pkfkchildhub.CreatedDT ASPKFKLinkChildCreatedDT
	  ,pkfkchildhub.IsActive AS PKFKLinkChildIsActive
	  ,hbkChildHub.HubBusinessKeyID AS PKFKLinkChildBKID
	  ,hbkChildHub.HubBKFieldID AS PKFKLinkChildBKFieldID
	  ,hbkChildHub.BKFriendlyName AS PKFKLinkChildBKFriendlyName
	  ,hbkChildHub.IsActive AS PKFKLinkChildBKIsActive
	  ,hbkChildHub.CreatedDT AS PKFKLinkChildBKCreatedDT
	  ,hbkfChildHub.FieldID AS PKFKLinkChildSourceBKFieldID
	  ,Childbkfield.FieldName AS PKFKLinkChildSourceBKFieldName
	  ,hbkfChildHub.CreatedDT AS PKFKLinkChildSourceBKFieldCreatedDT
	  ,hbkfChildHub.Isactive AS PKFKLinkChildSourceBKFieldIsActiv
	  ,fprimarykey.[SystemID] AS PrimaryKeySystemID
	  ,primarykeysystem.SystemName AS PrimaryKeySystemName
	  ,fprimarykey.[SystemAbbreviation] AS PrimaryKeySystemAbbreviation 
	  ,fprimarykey.[DatabaseName] AS PrimaryKeyDatabaseName  
	  ,fprimarykey.DataEntityID AS PrimaryKeyDataEntityID
	  ,fprimarykey.DataEntityName AS PrimaryKeyDataEntityName
	  ,pkfklinkf.PrimaryKeyFieldID AS PrimaryKeyFieldID
	  ,fprimarykey.FieldName AS PrimaryKeyFieldName
	  ,fforeignkey.[SystemID] AS ForeignKeySystemID
	  ,foreignkeysystem.SystemName AS ForeignKeySystemName
	  ,fforeignkey.[SystemAbbreviation] AS ForeignKeySystemAbbreviation 
	  ,fforeignkey.[DatabaseName] AS ForeignKeyDatabaseName  
	  ,fforeignkey.DataEntityID AS ForeignKeyDataEntityID
	  ,fforeignkey.DataEntityName AS ForeignKeyDataEntityName
	  ,pkfklinkf.ForeignKeyFieldID AS ForeignKeyFieldID
	  ,fforeignkey.FieldName AS ForeignKeyFieldName
	  ,pkfklinkf.CreatedDT AS PrimaryKeyFieldCreatedDT
	  ,pkfklinkf.IsActive AS PrimaryKeyFieldIsactive

FROM DMOD.Hub h
LEFT JOIN DMOD.HubBusinessKey hbk ON
hbk.HubID = h.HubID
LEFT JOIN DMOD.HubBusinessKeyField hbkf ON
hbk.HubBusinessKeyID = hbkf.HubBusinessKeyID
LEFT JOIN DC.vw_rpt_DatabaseFieldDetail bkfield ON
bkfield.FieldID = hbkf.FieldID
LEFT JOIN DC.[System] bksys ON
bksys.SystemID = bkfield.SystemID
LEFT JOIN DC.Field sourcebkfield ON
sourcebkfield.FieldID = hbkf.FieldID
LEFT JOIN DMOD.PKFKLink pkfklink ON
pkfklink.ParentHubID = h.HubID
LEFT JOIN DMOD.PkFKLinkField pkfklinkf ON
pkfklinkf.PKFKLinkID = pkfklink.PKFKLinkID
LEFT JOIN DC.vw_rpt_DatabaseFieldDetail fprimarykey ON
fprimarykey.FieldID = pkfklinkf.PrimaryKeyFieldID
LEFT JOIN DC.[System] primarykeysystem ON
primarykeysystem.SystemID = fprimarykey.SystemID
LEFT JOIN DC.vw_rpt_DatabaseFieldDetail fforeignkey ON
fforeignkey.FieldID = pkfklinkf.ForeignKeyFieldID
LEFT JOIN DC.[System] foreignkeysystem ON
foreignkeysystem.SystemID = fforeignkey.SystemID
LEFT JOIN DMOD.Hub pkfkchildhub ON
pkfkchildhub.HubID = pkfklink.ChildHubID
LEfT JOIN DMOD.HubBusinesskey hbkChildHub ON
hbkChildHub.HubID = pkfkchildhub.HubID
LEFT JOIN DMOD.HubBusinessKeyField hbkfChildHub ON
hbkfChildHub.HubBusinessKeyID = hbkChildHub.HubBusinessKeyID
LEFT JOIN DC.Field Childbkfield ON
Childbkfield.FieldID = hbkfChildHub.FieldID



GO
