SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Francois Seneka
-- Create Date: 16 OCt 2018
-- Description: Returns the FieldID for PKFKLink from SourceID
-- =============================================
CREATE FUNCTION [DMOD].[udf_GetStageFieldIDFromSourceBKFieldIDForPKFKLink]
(
@SourceFieldID int,
@FieldName varchar(100)
)
RETURNS INT
AS
BEGIN
DECLARE @Result int 
DECLARE @Lineage int = 
(
SELECT frstage.targetfieldid AS StageFieldID
	   
 from dc.fieldrelation frsource 
 inner join dc.fieldrelation frstage on 
 frsource.targetfieldid = frstage.sourcefieldid  
 inner join DC.vw_rpt_DatabaseFieldDetail fsource on 
 fsource.FieldID = frsource.SourceFieldID
  inner join DC.vw_rpt_DatabaseFieldDetail fods on 
 fods.FieldID = frsource.TargetFieldID
   inner join DC.vw_rpt_DatabaseFieldDetail fstage on 
 fstage.FieldID = frstage.TargetFieldID

where frsource.SourceFieldID = @SourceFieldID
AND fstage.DataEntityName like '%_KEYS'
AND fstage.FieldName = @FieldName
)
SET @Result = @Lineage
RETURN @Result
END

GO
