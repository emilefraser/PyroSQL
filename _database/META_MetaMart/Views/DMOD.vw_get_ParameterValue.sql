SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [DMOD].[vw_get_ParameterValue] AS
SELECT parm.ParameterCode,
	   parm.ParameterValueType,
	   parmval.[ValueDecimal],
	   parmval.[ValueInt],
	   parmval.[ValueDate],
	   parmval.[ValueVarchar]
  FROM DMOD.Parameter parm
	   INNER JOIN (SELECT * FROM DMOD.ParameterValue WHERE IsActive = 1 AND ClosedDT IS NULL) AS parmval ON
			parmval.ParameterID = parm.ParameterID

GO
