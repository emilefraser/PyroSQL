SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [DMOD].[vw_rpt_Validate_DataEntities_Without_DataentityType]
as
SELECT db.DatabaseName,db.DatabaseID,de.* FROM DC.DataEntity DE
LEFT JOIN DC.[Schema] S
ON S.SchemaID = DE.SchemaID
LEFT JOIN DC.[DATABASE] DB
ON DB.DatabaseID = S.DatabaseID
WHERE DataEntityTypeID IS NULL

GO
