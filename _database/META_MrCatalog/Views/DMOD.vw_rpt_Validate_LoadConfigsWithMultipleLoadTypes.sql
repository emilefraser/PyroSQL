SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_rpt_Validate_LoadConfigsWithMultipleLoadTypes]
AS
SELECT DISTINCT
			    lc.LoadConfigID AS LoadConfigID
			  , lc.SourceDataEntityID AS SourceDataEntityID
			  , fd.DataEntityName AS SourceDataentityName
			  , lc.TargetDataEntityID AS TargetDataEntityID
			  , fd1.DataEntityName AS TargetDataentityName
			  , lc.LoadTypeID AS LoadTypeID
FROM 
	DMOD.LoadConfig lc
		INNER JOIN 
				(SELECT  lc1.SourceDataEntityID 
					   , lc1.TargetDataEntityID 
				 FROM DMOD.LoadConfig lc1
				 GROUP BY lc1.SourceDataEntityID 
						, lc1.TargetDataEntityID 
				 HAVING COUNT(CONVERT(varchar(50),lc1.SourceDataEntityID)+'.'+CONVERT(varchar(50), lc1.TargetDataEntityID)) > 1
				 ) load ON
		lc.SourceDataEntityID = load.SourceDataEntityID
		AND  lc.TargetDataEntityID = load.TargetDataEntityID

		LEFT JOIN DC.vw_rpt_DatabaseFieldDetail fd ON
				 fd.DataEntityID = lc.SourceDataEntityID	
		
		LEFT JOIN DC.vw_rpt_DatabaseFieldDetail fd1 ON
				 fd1.DataEntityID = lc.TargetDataEntityID	


GO
