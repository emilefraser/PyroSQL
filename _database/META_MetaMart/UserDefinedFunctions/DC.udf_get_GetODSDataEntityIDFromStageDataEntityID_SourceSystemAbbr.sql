SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [DC].[udf_get_GetODSDataEntityIDFromStageDataEntityID_SourceSystemAbbr]
(
    -- Add the parameters for the function here
    @CurrentDataEntityID int
)
RETURNS INT
AS
BEGIN

DECLARE @CurrentDataEntityName varchar(100) = (SELECT RIGHT(DataEntityName,LEN(DataEntityName)-4) FROM DC.DataEntity WHERE DataEntityID = @CurrentDataEntityID)
DECLARE @ODSDataEntityID INT
DECLARE @DataBaseType VARCHAR(100) = 'ODS%'
SET @ODSDataEntityID =
(SELECT DISTINCT de.DataEntityID FROM dc.field f
INNER JOIN DC.DataEntity de ON
de.DataEntityID = f.DataEntityID
INNER JOIN DC.[Schema] s ON
s.SchemaID = de.SchemaID
INNER JOIN DC.[Database] db ON
db.DatabaseID = s.DataBaseID
WHERE db.DatabaseName like @DataBaseType
AND DataEntityName = @CurrentDataEntityName
)

RETURN @ODSDataEntityID

END

GO
