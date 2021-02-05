CREATE PROCEDURE [Sample].[PrimaryKeyCheck_Product]
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
'[Sample].[Source_Product]'
,''
,isnull(cast([ProductID] as varchar(max)),'*NULL*') + isnull(cast([ProductModelID] as varchar(max)),'*NULL*')
,'*PK CONTAINS NULL*'
,cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
,null
FROM [Sample].[Source_Product] S
where cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max)) is null
INSERT INTO [#T]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
'[Sample].[Source_Product]'
,''
,cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
,'*PK NOT UNIQUE*'
,CAST(count(*) as varchar(max))
,null
FROM [Sample].[Source_Product] S
where cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max)) is not null
group by cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
having COUNT(*) > 1
IF '#T'='#T'
BEGIN
select * from #T
drop table #T
END

END
