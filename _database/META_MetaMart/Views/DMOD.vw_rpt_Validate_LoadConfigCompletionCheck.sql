SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON





CREATE VIEW [DMOD].[vw_rpt_Validate_LoadConfigCompletionCheck]
AS

SELECT    *
FROM    (
            SELECT    DISTINCT vrdfd.DatabaseName
                    , vrdfd.SchemaName
                    , vrdfd.DataEntityID 
                    , vrdfd.DataEntityName
            FROM    DC.vw_rpt_DatabaseFieldDetail vrdfd
           -- WHERE    vrdfd.DatabaseName IN ('DEV_StageArea', 'DEV_DataVault')
        ) dc
    LEFT JOIN DMOD.LoadConfig lc 
                
        ON lc.TargetDataEntityID = dc.DataEntityID
WHERE    dc.DataEntityID IS NULL

GO
