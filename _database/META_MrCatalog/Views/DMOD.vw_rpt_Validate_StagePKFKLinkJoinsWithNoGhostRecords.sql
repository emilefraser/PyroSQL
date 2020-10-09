SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON








CREATE VIEW [DMOD].[vw_rpt_Validate_StagePKFKLinkJoinsWithNoGhostRecords]
AS

/*-------------------------------------------------------------------------------------------------

Author : Francois Senekal
Created Date : 2019/09/13

--------------------------------------------------------------------------------------------------*/
--SELECT l.LinkName 
--	  ,fkf.PKFKLinkID AS PKFKLinkID
--      ,fkfd.DataEntityID AS FKDataEntityID
--	  ,fkfd.DataEntityName AS FKDataEntityName
--	  ,pkfd.DataEntityID AS PKDataEntityID
--	  ,pkfd.DataEntityName  AS PKDataEntityName
--      ,fkfd.FieldID AS FKFieldID
--	  ,fkfd.FieldName AS ForeignKeyFieldName
--	  ,pkfd.FieldID AS PKFieldID
--	  ,pkfd.FieldName AS PKFieldName
--	  ,hubfk.HubName
--	  ,fkfr.TargetDataEntity
--	  ,fkfr.SourceFieldID
--	  ,bkfk.FieldID AS FKBKFieldID
--	  ,bkfk.FieldName AS FKBKFieldName
--	  ,hubpk.HubName
--	  ,pkfr.TargetDataEntity
--	  ,bkpk.FieldID AS PKBKFieldID
--	  ,bkpk.FieldName AS PKBKFieldName
--	  ,fkfr.FieldName
--	  ,pkfr.FieldName
--,[DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID](bkfk.FieldID,0) AS StagePKBKID
--	  ,[DC].[udf_get_StageLevelBKFieldID_FromSourceBKFieldID](bkpk.FieldID,0) AS StageFKBKID
--	  , pkfr.TargetDataEntity,hubfk.HubName
--	  ,fkfr.TargetDataEntity
--	  ,pkfr.SourceFieldID , bkpk.FieldID

SELECT DISTINCT  'SELECT COUNT(1) AS [JoinCount],'''
				+fkfr.SchemaName +'.'
				+fkfr.TargetDataEntity +
			    ''' AS [FKTableName] ,'''
				+fkfr.DataEntityName +
			    ''' AS [FKTableName] ,'''
				+pkfr.TargetDataEntity +
			    ''' AS [PKTableName] FROM '
                +fkfr.SchemaName +'.'
				+fkfr.TargetDataEntity + 
				
				' s INNER JOIN ' 
				+fkfr.SchemaName +'.'
				+pkfr.TargetDataEntity +
				' t ON s.'
				+fkfr.FieldName+
				' = t.'
				+pkfr.FieldName+
				' WHERE s.'
				+ fkfr.FieldName +
				' != ''3FEDA0153EEE1380B496298450DC5A74324EB8C1'' UNION ALL' 
				--+ CASE ROW_NUMBER() OVER( ORDER BY l.ParentHubID ) WHEN MAX(ROW_NUMBER() OVER( ORDER BY l.ParentHubID )) THEN ''
				--ELSE ' UNION ALL'
				--END
				 AS ValidationScript
FROM DMOD.PKFKLinkField fkf
INNER JOIN DC.vw_rpt_DatabaseFieldDetail fkfd ON
	fkfd.FieldID = fkf.ForeignKeyFieldID
INNER JOIN DC.vw_rpt_DatabaseFieldDetail pkfd ON
	pkfd.FieldID = fkf.PrimaryKeyFieldID
INNER JOIN DMOD.PKFKLink l ON
	l.PKFKLinkID = fkf.PKFKLinkID
INNER JOIN (	SELECT DataEntityID
					  ,DataEntityName
					  ,kf.FieldID
					  ,fd.FieldName 
				FROM DMOD.HubBusinessKeyField kf 
				INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON
					fd.FieldID = kf.FieldID
			) bkfk ON
					bkfk.DataEntityID = fkfd.DataEntityID
INNER JOIN (	SELECT DataEntityID
					  ,DataEntityName
					  ,kf.FieldID
					  ,fd.FieldName 
				FROM DMOD.HubBusinessKeyField kf 
				INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON
					fd.FieldID = kf.FieldID
			) bkpk ON
					bkpk.DataEntityID = pkfd.DataEntityID
INNER JOIN dmod.Hub hubpk ON 
hubpk.HubID = l.ParentHubID
INNER JOIN DMOD.Hub hubfk ON 
hubfk.HubID = l.ChildHubID
--INNER JOIN DC.FieldRelation frpk ON 
--frpk.SourceFieldID = bkfk.FieldID
INNER JOIN (SELECT fr.SourceFieldID
			      ,fr.TargetFieldID
				  ,fd1.FieldName
				  ,fd1.DataEntityName AS TargetDataEntity
				  ,fd.DataEntityName
				  ,fd1.SchemaName
		 	FROM DC.FieldRelation fr
			INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON
				fd.FieldID = fr.SourceFieldID
			INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd1 ON
				fd1.FieldID = fr.TargetFieldID

			WHERE   fd1.FieldName like 'BKHASH'
				and fd1.DataEntityName like '%KEYS'
			) fkfr ON
				fkfr.SourceFieldID = bkpk.FieldID
					--AND fkfr.TargetDataEntity like '%'+REPLACE(hubpk.HubName,'HUB_','')+'%'
					--'%'+REPLACE(hubfk.HubName,'HUB_','')+'%'
INNER JOIN (SELECT fr.SourceFieldID
				  ,fr.TargetFieldID
				  ,fd1.FieldName
				  ,fd1.DataEntityName AS TargetDataEntity
				  ,fd.DataEntityName
			FROM DC.FieldRelation fr
			INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd ON
				fd.FieldID = fr.SourceFieldID
			INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd1 ON
				fd1.FieldID = fr.TargetFieldID

			WHERE   fd1.FieldName like 'HK_%'
				and fd1.DataEntityName like '%KEYS'
			) pkfr ON
				pkfr.SourceFieldID = bkfk.FieldID

WHERE 
--fkfd.FieldID is null
--and 
fkf.IsActive = 1
and Fkfr.TargetDataEntity like '%'+REPLACE(pkfr.FieldName,'HK_','')+'%'
--SELECT fd.DataEntityName,fr.SourceFieldID,fd.FieldName 
--	  ,fd1.DataEntityName,fr.TargetFieldID,fd1.FieldName
--from DC.FieldRelation fr
--INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd
--ON fd.FieldID = fr.SourceFieldID
--INNER JOIN DC.vw_rpt_DatabaseFieldDetail fd1
--ON fd1.FieldID = fr.TargetFieldID


GO
