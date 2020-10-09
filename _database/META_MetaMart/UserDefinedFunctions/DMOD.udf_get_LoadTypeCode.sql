SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- SELECT [DMOD].[udf_get_LoadTypeCode](54)
-- SELECT [DMOD].[udf_get_LoadTypeCode](70)
-- SELECT [DMOD].[udf_get_LoadTypeCode](69)
CREATE FUNCTION [DMOD].[udf_get_LoadTypeCode](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @LoadTypeCode VARCHAR(MAX)
	
	DECLARE @StageAreaTableName VARCHAR(MAX) = '';
	DECLARE @StageAreaTableType VARCHAR(MAX) = '';
  
	 SET  @StageAreaTableName = 
	 ( 
		SELECT 
			DC.udf_GetDataEntityNameForDataEntityID(TargetDataEntityID)
		FROM 
			[DMOD].[LoadConfig] AS lc
		WHERE 
			lc.LoadConfigID = @LoadConfigID
	)

	SET @StageAreaTableType = 
	(
		SELECT
			CASE SUBSTRING(@StageAreaTableName, LEN(@StageAreaTableName) - 3, 4)
				WHEN 'KEYS' THEN 'KEYS'
				WHEN '_LVD' THEN 'SAT'
				WHEN '_MVD' THEN 'SAT'
				WHEN '_HVD' THEN 'SAT'
							ELSE 'UNK'
			END
	)

	SET @LoadTypeCode = 
	(
		SELECT 
			IIF(@StageAreaTableType = 'SAT'
					, LEFT(lt.LoadTypeCode, LEN(lt.LoadTypeCode) - 4) + SUBSTRING(@StageAreaTableName, LEN(@StageAreaTableName) - 3, 4)   
					, lt.LoadTypeCode)
			FROM 
				DMOD.LoadConfig AS lc 
			INNER JOIN 
				DMOD.LoadType AS lt 
				ON lc.LoadTypeID = lt.LoadTypeID 
			WHERE 
				LoadConfigID = @LoadConfigID
	)

	RETURN @LoadTypeCode;
END;

GO
