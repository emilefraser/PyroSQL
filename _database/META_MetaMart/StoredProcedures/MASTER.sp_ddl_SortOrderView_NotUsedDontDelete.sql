SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
--Sample Execution: [MASTER].[sp_ddl_SortOrderView_NotUsedDontDelete] 'LABSAMPLE'
CREATE PROCEDURE [MASTER].[sp_ddl_SortOrderView_NotUsedDontDelete]
	@SortOrderGroupCode VARCHAR(20)
AS

--Testing
--DECLARE @SortOrderGroupCode VARCHAR(20) = 'LABSAMPLE'

DECLARE @CreateSql VARCHAR(MAX),
	    @DropSql VARCHAR(MAX),	
		@SortOrderGroupFieldList VARCHAR(MAX)

SELECT @SortOrderGroupFieldList = 'FieldList1,FieldList2' --[MASTER].[udf_FieldListForSortOrderGroup](@SortOrderGroupCode)

SET @DropSql = 'IF EXISTS (SELECT 1 FROM sys.views v INNER JOIN sys.schemas s ON s.schema_id = v.schema_id WHERE v.name = ''vw_rpt_SortOrder_' + @SortOrderGroupCode + ''' AND s.name = ''MASTER'')
	DROP VIEW [MASTER].vw_rpt_SortOrder_' + @SortOrderGroupCode

SET @CreateSql =
'CREATE VIEW [MASTER].vw_rpt_SortOrder_' + @SortOrderGroupCode + ' AS
SELECT SortOrderGroupName, SortOrderGroupCode, SortOrder, ' + @SortOrderGroupFieldList + '
FROM
(SELECT SortOrderGroupName, SortOrderGroupCode, SortOrderValueGroupingID, SortOrder, FieldName, DataValue
   FROM [MASTER].vw_SortOrderNoPivot
  WHERE SortOrderGroupCode = ''' + @SortOrderGroupCode + ''') AS SourceTable
PIVOT
(MAX(DataValue) FOR FieldName IN (' + @SortOrderGroupFieldList + ')
) AS PivotTable;'

SELECT @DropSql
SELECT @CreateSql
--EXEC (@DropSql)
--EXEC (@CreateSql)

GO
