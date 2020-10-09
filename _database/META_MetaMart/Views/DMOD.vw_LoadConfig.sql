SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE view [DMOD].[vw_LoadConfig]
AS
    select  con.LoadConfigID, 
			con.LoadTypeID,
			lt.LoadTypeCode,
			lt.LoadTypeName, 
			lt.DatabasePurposeID,
			dp.DatabasePurposeCode,
			dp.DatabasePurposeName,
			lt.DataEntityTypeID,
			det.DataEntityTypeCode,
			det.DataEntityTypeName,
			det.DataEntityNamingPrefix,
			det.DataEntityNamingSuffix,
			lt.isExternalTable,
			lt.IsActive AS loadtype_IsActive,
			con.SourceDataEntityID,
			con.TargetDataEntityID,
			con.IsSetForReloadOnNextRun,
			con.OffsetDays, 
			con.IsActive AS config_IsActive, 
			con.CreatedDT_FieldID,
			con.UpdatedDT_FieldID
		, sourcede.DatabaseID AS Source_DatabaseID
        , sourcede.DatabaseName as Source_DB
        , sourcede.DataEntityName as Source_DEName
		, sourcede.SchemaID as Source_SchemaID
		, sourcede.SchemaName as Source_SchemaName
		, targetde.DatabaseID AS Target_DatabaseID
        , targetde.DatabaseName as Target_DB
        , targetde.DataEntityName as Target_DEName
		, targetde.SchemaID as Target_SchemaID
		, targetde.SchemaName as Target_SchemaName
from    DMOD.LoadConfig con
	inner join DMOD.LoadType AS lt
	ON lt.LoadTypeID = con.LoadTypeID
    inner join
                (
                    select    distinct DatabaseID, DatabaseName
                            , SchemaID, SchemaName
                            , DataEntityID, DataEntityName
                    from    DC.vw_rpt_DatabaseFieldDetail
                ) sourcede on sourcede.DataEntityID = con.SourceDataEntityID
    left join
                (
                    select    distinct DatabaseID, DatabaseName
                            , SchemaID, SchemaName
                            , DataEntityID, DataEntityName
                    from    DC.vw_rpt_DatabaseFieldDetail
                )targetde on targetde.DataEntityID = con.TargetDataEntityID
	INNER JOIN 
		DC.DatabasePurpose AS dp
		ON dp.DatabasePurposeID = lt.DatabasePurposeID
	INNER JOIN 
		DC.DataEntityType AS det
		ON	det.DataEntityTypeID = lt.DataEntityTypeID


GO
