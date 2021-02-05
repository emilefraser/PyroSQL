/*CREATE PROCEDURE Test
AS
BEGIN
IF '#T'='#T'
BEGIN
SELECT TOP 0 * INTO #T FROM DSQLT.CompareResult
END
INSERT INTO [#T]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
'[Sample].[Target_Product]'
,'[Sample].[Source_Product]'
,CAST(cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max)) as nvarchar(max))
,''
,'EXISTS'
,null
FROM [Sample].[Target_Product] S
left outer join [Sample].[Source_Product] T
on [S].[ProductID]=[T].[ProductID] and [S].[ProductModelID]=[T].[ProductModelID]
where cast([T].[ProductID] as varchar(max)) + cast([T].[ProductModelID] as varchar(max)) is null
INSERT INTO [#T]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
'[Sample].[Target_Product]'
,'[Sample].[Source_Product]'
,CAST(cast([T].[ProductID] as varchar(max)) + cast([T].[ProductModelID] as varchar(max)) as nvarchar(max))
,''
,null
,'EXISTS'
FROM [Sample].[Source_Product] T
left outer join [Sample].[Target_Product] S
on [S].[ProductID]=[T].[ProductID] and [S].[ProductModelID]=[T].[ProductModelID]
where cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max)) is null
IF '#T'='#T'
BEGIN
select * from #T
drop table #T
END

END*/