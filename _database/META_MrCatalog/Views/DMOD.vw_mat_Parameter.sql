SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
CREATE VIEW [DMOD].[vw_mat_Parameter] AS

SELECT P.ParameterID AS [Parameter ID],
	   P.ParameterCode AS [Parameter Code],
	   P.ParameterDescription AS [Parameter Description],
	   P.ParameterValueType AS [Parameter Value Type],
	   PV.ParameterValueID AS [Parameter Value ID],
	   PV.ValueInt AS [Value Int],
	   PV.ValueDate AS [Value Date],
	   PV.ValueVarchar AS [Value Varchar],
	   PV.ValueDecimal AS [Value Decimal],
	   P.CreatedDT AS [Created Date],
	   P.UpdatedDT AS [Updated Date],
	   P.IsActive AS [Is Active]

FROM [DMOD].[Parameter] P
LEFT JOIN [DMOD].[ParameterValue] PV
ON 
P.ParameterID = PV.ParameterID

GO
