SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [DC].[sp_compare_ViewsToTables]
AS
select de.DataEntityName,de.DataEntityID , fd.FieldName ,fd.FieldID, de2.DataEntityName ,de2.FieldName
from dc.vw_rpt_databasefielddetail fd 
inner join 
	(SELECT DataEntityID,DataEntityName 
	 FROM dc.DataEntity 
	 WHERE DataEntityTypeID = 2) 
	 de  ON
		de.DataEntityID = fd.DataEntityID
FULL OUTER JOIN 
	(SELECT distinct de1.DataEntityName,fd1.FieldName 
	 FROM dc.vw_rpt_databasefielddetail fd1 
			INNER JOIN DC.DataEntity de1 ON 
				de1.DataEntityID = fd1.DataEntityID 
	 where fd1.databasename = 'DEV_ODS_D365' 
		AND de1.DataEntityTypeID is null) 
		de2 ON 
			'vw_DMOD_'+de2.DataEntityName = de.DataEntityName
				AND de2.FieldName = fd.FieldName
where fd.databasename = 'DEV_ODS_D365'
--AND fd.DataEntityName !='Fields'
AND (de2.DataEntityName is null or de2.FieldName is null)
--AND fd.DataEntityName !='vw_DMOD_StockTransaction'

--AND fd.DataEntityName !='vw_DMOD_SalesPerson'
--AND fd.DataEntityName !='vw_DMOD_BI_CommissionSalesGroupStaging_'


GO
