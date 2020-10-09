SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [DYNREP].[udf_get_ConfigValueForReportLine] 
(
	-- Add the parameters for the function here
	@ConfigType varchar(100)
	, @ReportBaseID int
)
RETURNS varchar(100)
AS
BEGIN
	-- Declare the return variable here
	
DECLARE @ConfigValue varchar(100) =
(
SELECT	COALESCE(Config.Value,DefaultConfig.Value) as Value
FROM

(
SELECT	@ConfigType as ConfigType, ConfigMasterDefaultValue AS Value
FROM	DYNREP.ConfigMaster
WHERE	ConfigMasterCode = @ConfigType
) DefaultConfig

LEFT JOIN

(
	SELECT	@ConfigType as ConfigType, [Value]
	FROM	
	(
		SELECT	DISTINCT @ConfigType AS ConfigType,
			CASE WHEN lcm.ConfigMasterCode = @ConfigType
					THEN lec.[Value]
				WHEN icm.ConfigMasterCode = @ConfigType 
						AND (
								lcm.ConfigMasterCode <> @ConfigType 
								OR 
								lcm.ConfigMasterCode IS NULL
							)				
					THEN iec.[Value] 
				WHEN pcm.ConfigMasterCode = @ConfigType
						AND (
								lcm.ConfigMasterCode <> @ConfigType
								OR
								lcm.ConfigMasterCode IS NULL
							)
						AND	(
							icm.ConfigMasterCode <> @ConfigType 
							OR
							icm.ConfigMasterCode IS NULL
							)
					THEN pec.[Value]
				ELSE NULL
				END AS [Value]
				,CASE WHEN lcm.ConfigMasterCode = @ConfigType
					THEN 3
				WHEN icm.ConfigMasterCode = @ConfigType 
						AND (
								lcm.ConfigMasterCode <> @ConfigType 
								OR 
								lcm.ConfigMasterCode IS NULL
							)				
					THEN 2 
				WHEN pcm.ConfigMasterCode = @ConfigType
						AND (
								lcm.ConfigMasterCode <> @ConfigType
								OR
								lcm.ConfigMasterCode IS NULL
							)
						AND	(
							icm.ConfigMasterCode <> @ConfigType 
							OR
							icm.ConfigMasterCode IS NULL
							)
					THEN 1
				ELSE NULL
				END AS [Level]
		FROM	DYNREP.ReportLineExtension rl
		LEFT JOIN	DYNREP.EntityConfig lec ON rl.ReportBaseID = lec.ReportBaseID
		LEFT JOIN	DYNREP.ConfigMaster lcm ON lec.ConfigID = lcm.ConfigMasterID
		INNER JOIN	DYNREP.ReportBase lrb ON rl.ReportBaseID = lrb.ReportBaseID
		LEFT JOIN	DYNREP.EntityConfig iec ON lrb.ReportBaseParentID = iec.ReportBaseID
		LEFT JOIN	DYNREP.ConfigMaster icm ON iec.ConfigID = icm.ConfigMasterID
		INNER JOIN	DYNREP.ReportBase prb ON lrb.ReportBaseParentID = prb.ReportBaseID
		LEFT JOIN	DYNREP.EntityConfig pec ON prb.ReportBaseParentID = pec.ReportBaseID
		LEFT JOIN	DYNREP.ConfigMaster pcm ON pec.ConfigID = pcm.ConfigMasterID
		WHERE lrb.ReportBaseID = @ReportBaseID
	)dr
	INNER JOIN	
		(
		SELECT	cm.ConfigMasterCode, MAX(rb.ReportBaseLevelID) AS LowestLevel
		FROM	DYNREP.EntityConfig ec
			INNER JOIN	DYNREP.ConfigMaster cm ON ec.ConfigID = cm.ConfigMasterID
			INNER JOIN	DYNREP.ReportBase rb ON ec.ReportBaseID = rb.ReportBaseID
		GROUP BY cm.ConfigMasterCode
		)ml ON ml.ConfigMasterCode = @ConfigType
				AND ml.LowestLevel = dr.[Level]
)Config ON DefaultConfig.ConfigType = Config.ConfigType
)
	-- Return the result of the function
	RETURN @ConfigValue

END

GO
