SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[GetSourceEntities]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [adf].[GetSourceEntities] ()

RETURNS TABLE 
AS
RETURN

SELECT DISTINCT 
	[SourceEntityName]      
FROM 
	[adf].[LoadConfig]
WHERE
	IsActive = 1
' 
END
GO
