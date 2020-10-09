SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_rpt_Validate_HubDataEntityNotSameAsForeignKeyDataEntity] AS

select	H.HubID, H.HubName
		, hbk.HubBusinessKeyID
		, hbk.BKFriendlyName
		, hbkf.FieldID AS HubBusinessKeyFieldID
		, hubfield.FieldName AS HubBusinessKeyFieldName
		, hubfield.DataEntityID AS HubBusinessKeyFieldDataEntityID
		, hubfield.DataEntityName AS HubBusinessKeyFieldDataEntity
		, hbkf.IsBaseEntityField AS HubBusinessKeyFieldIsBaseEntityField
		, [DC].[udf_get_SourceSystemAbbrv_for_DataEntityID](DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID)) AS HubBusinessKeyFieldSystemAbbreviation
		, [DC].[udf_get_SourceSystemAbbrv_for_DataEntityID](DC.udf_get_DataEntityID_from_FieldID(linkf.ForeignKeyFieldID)) AS LinkFo
		, link.PKFKLinkID
		, link.LinkName
		, link.ParentHubID
		, linkf.ForeignKeyFieldID
		, fklinkfield.FieldName AS ForeignKeyFieldName
		, fklinkfield.DataEntityID AS ForeignKeyDataEntityID
		, fklinkfield.DataEntityName AS ForeignKeyDataEntityName
		, DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID) as Hub_DataEntityID
		, DC.udf_get_DataEntityID_from_FieldID(linkf.ForeignKeyFieldID) as ForeingKey_DataEntityID
from	DMOD.Hub h
	left join DMOD.HubBusinessKey hbk on hbk.HubID = h.HubID
	left join DMOD.HubBusinessKeyField hbkf on hbkf.HubBusinessKeyID = hbk.HubBusinessKeyID
		left join DC.vw_rpt_DatabaseFieldDetail hubfield on hubfield.FieldID = hbkf.FieldID
	left join DMOD.PKFKLink link on h.HubID = link.ChildHubID
	left join DMOD.PKFKLinkField linkf on linkf.PKFKLinkID = link.PKFKLinkID
		left join DC.vw_rpt_DatabaseFieldDetail fklinkfield on fklinkfield.FieldID = linkf.ForeignKeyFieldID
where	1=1
	and DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID) <> DC.udf_get_DataEntityID_from_FieldID(linkf.ForeignKeyFieldID)
	and DC.udf_get_SourceSystem_DataEntityID(DC.udf_get_DataEntityID_from_FieldID(hbkf.FieldID)) = DC.udf_get_SourceSystem_DataEntityID(DC.udf_get_DataEntityID_from_FieldID(linkf.ForeignKeyFieldID))

GO
