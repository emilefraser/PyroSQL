SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [DC].[sp_Validate_FieldRelationsExistForTargetDataEntityID]
@TargetDataEntityID int
AS

select fdsource.DataEntityID AS SourceDataEntityID
      ,fdsource.DataEntityName AS SourceDataEntityName
	  ,fdsource.FieldName AS SourceFieldName
	  ,fdtarget.DataEntityID AS TargetDataEntityID
	  ,fdtarget.DataEntityName AS TargetDataEntityName
	  ,fdtarget.FieldName AS TargetFieldName
from DC.FieldRelation fr
inner join DC.vw_rpt_DatabaseFieldDetail fdsource on
fdsource.FieldID = fr.SourceFieldID
inner join DC.vw_rpt_DatabaseFieldDetail fdtarget on 
fdtarget.FieldID = fr.TargetFieldID
where fdtarget.DataEntityID = @TargetDataEntityID
ORDER BY fdsource.FieldName ASC


GO
