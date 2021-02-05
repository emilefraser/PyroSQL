CREATE PROCEDURE Sample.Compare_Product
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
,'[Sample].[Target_Product]'
,cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
,'*INSERT*'
,'EXISTS'
,null
FROM [Sample].[Source_Product] S
left outer join [Sample].[Target_Product] T
on [S].[ProductID]=[T].[ProductID] and [S].[ProductModelID]=[T].[ProductModelID]
where T.[ProductID] is null
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
,'[Sample].[Target_Product]'
,cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
,'*DELETE*'
,null
,'EXISTS'
FROM [Sample].[Target_Product] S
left outer join [Sample].[Source_Product] T
on [S].[ProductID]=[T].[ProductID] and [S].[ProductModelID]=[T].[ProductModelID]
where T.[ProductID] is null
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
,'[Sample].[Target_Product]'
, cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
,'[Name]'
,CAST(S.[Name] as nvarchar(max))
,CAST(T.[Name] as nvarchar(max))
FROM [Sample].[Source_Product] S
join [Sample].[Target_Product] T
on [S].[ProductID]=[T].[ProductID] and [S].[ProductModelID]=[T].[ProductModelID]
where ( cast([S].[Name] as nvarchar(100)) <> cast([T].[Name] as nvarchar(100)) or ([S].[Name] is null and [T].[Name] is not null) or ([S].[Name] is not null and [T].[Name] is null) )

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
,'[Sample].[Target_Product]'
, cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
,'[Color]'
,CAST(S.[Color] as nvarchar(max))
,CAST(T.[Color] as nvarchar(max))
FROM [Sample].[Source_Product] S
join [Sample].[Target_Product] T
on [S].[ProductID]=[T].[ProductID] and [S].[ProductModelID]=[T].[ProductModelID]
where ( [S].[Color] <> [T].[Color] or ([S].[Color] is null and [T].[Color] is not null) or ([S].[Color] is not null and [T].[Color] is null) )

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
,'[Sample].[Target_Product]'
, cast([S].[ProductID] as varchar(max)) + cast([S].[ProductModelID] as varchar(max))
,'[Created]'
,CAST(S.[Created] as nvarchar(max))
,CAST(T.[Created] as nvarchar(max))
FROM [Sample].[Source_Product] S
join [Sample].[Target_Product] T
on [S].[ProductID]=[T].[ProductID] and [S].[ProductModelID]=[T].[ProductModelID]
where ( [S].[Created] <> [T].[Created] or ([S].[Created] is null and [T].[Created] is not null) or ([S].[Created] is not null and [T].[Created] is null) )


IF '#T'='#T'
BEGIN
select * from #T
drop table #T
END

END