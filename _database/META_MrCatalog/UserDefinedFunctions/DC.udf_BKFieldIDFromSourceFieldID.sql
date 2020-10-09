SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Francois Senekal 
-- Create Date: 25-06-2019
-- Description: Returns the stage fieldid for a selected sourceid for the BK
-- =============================================
CREATE FUNCTION [DC].[udf_BKFieldIDFromSourceFieldID]
(
    @SourceFieldID INT,
	@DataEntityType varchar(100)
)
RETURNS INT
AS


BEGIN
DECLARE @Type varchar(100) 
SET @Type = @DataEntityType+'_HK_%' 

DECLARE @StageFieldID int =
(select frods.TargetFieldID 
	 
from DC.FieldRelation frsource 
inner join dc.fieldrelation frods on
frsource.TargetFieldID = frods.SourceFieldID
inner join dc.vw_rpt_DatabaseFieldDetail dbfd on
dbfd.FieldID = frods.TargetFieldID
inner join dc.field fsource on
fsource.FieldID = frsource.SourceFieldID
inner  join DC.Field ftarget on
ftarget.FieldID = frods.TargetFieldID
where frsource.SourceFieldID = @SourceFieldID
and dbfd.DataEntityName not like '%_hist'
and dbfd.DataEntityName like '%_keys'
and ftarget.FieldName like @Type)

RETURN @StageFieldID
END


GO
