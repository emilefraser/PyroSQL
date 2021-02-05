




CREATE PROCEDURE [DSQLT].[@TableComparisonSingleField]
AS
DECLARE	@2 int
DECLARE	@6 int
DECLARE	@7 int
BEGIN
-- feststellen, ob die Spalte bei einem Datensatz geändert wurde
INSERT INTO [@3].[@3]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
 '@4'  -- @Source
,'@5'  -- @Target
, @6  -- @PrimaryKeyExpression
,'@1'  -- @ColumnName   
,CAST(S.[@1] as nvarchar(max))  -- Evaluate @ColumnName to SourceValue
,CAST(T.[@1] as nvarchar(max))  -- Evaluate @ColumnName to TargetValue
FROM [@4].[@4] S  -- @Source
join [@5].[@5] T  -- @Target
	on (@7=@7)  -- @PrimaryKeyCompareExpression
where (@2=@2) -- @ColumnCompareExpression

END