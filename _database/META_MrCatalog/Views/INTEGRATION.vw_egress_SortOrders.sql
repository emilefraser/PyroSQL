SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [INTEGRATION].[vw_egress_SortOrders] AS
SELECT sog.SortOrderGroupName, sog.SortOrderGroupCode
	,f.FieldID, f.FieldName
	,de.DataEntityName
	,s.SchemaName
	,d.DatabaseName
	,sov.SortOrder, sov.DataValue
  FROM [MASTER].SortOrderGrouping sog
		LEFT JOIN DC.Field f ON f.FieldID = sog.FieldID
		LEFT JOIN DC.DataEntity de ON f.DataEntityID = de.DataEntityID
		LEFT JOIN DC.[Schema] s ON de.SchemaID = s.SchemaID
		LEFT JOIN DC.[Database] d ON s.DatabaseID = d.DatabaseID
		LEFT JOIN [MASTER].SortOrderValue sov ON sog.SortOrderGroupingID = sov.SortOrderGroupingID
	   

GO
