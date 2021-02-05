create FUNCTION [DSQLT].[Columns]
(@Object NVARCHAR (MAX)='')
RETURNS @Result TABLE (
	[Name] [sysname] NOT NULL,
	[NameQ] [nvarchar](max) NOT NULL,
	[Column] [sysname] NOT NULL,
	[ColumnQ] [nvarchar](max) NOT NULL,
	[ObjectColumn] [nvarchar](max) NOT NULL,
	[ObjectColumnQ] [nvarchar](max) NOT NULL,
	[SchemaObjectColumn] [nvarchar](max) NOT NULL,
	[SchemaObjectColumnQ] [nvarchar](max) NOT NULL,
	[Type] [sysname] NOT NULL,
	[Type_Id] [tinyint] NOT NULL,
	[is_primary_key] [int] NOT NULL,
	[is_nullable] [bit] NOT NULL,
	[Length] [smallint] NOT NULL,
	[Precision] [tinyint] NOT NULL,
	[Scale] [tinyint] NOT NULL,
	[Order] [int] NOT NULL
)
AS
BEGIN
INSERT @Result
	select top 100 percent
	C.[Name] as [Name]
	,QUOTENAME(C.name) as NameQ
	,C.name as [Column]
	,QUOTENAME(C.name) as ColumnQ
	,O.name+'.'+C.name as ObjectColumn
	,QUOTENAME(O.name)+'.'+QUOTENAME(C.name) as ObjectColumnQ
	,S.name+'.'+O.name+'.'+C.name as SchemaObjectColumn
	,QUOTENAME(S.name)+'.'+QUOTENAME(O.name)+'.'+QUOTENAME(C.name) as SchemaObjectColumnQ
    ,TYPE_NAME(c.system_type_id) AS [Type] 
    ,c.system_type_id AS [Type_Id] 
	,case when Y.index_id is null then 0 else 1 end as is_primary_key
	,C.is_nullable
	,C.max_length as Length
	,C.precision as Precision
	,C.scale as Scale
	,C.column_id as [Order]
	from sys.objects O
	join sys.schemas S on S.schema_id=O.schema_id
	join sys.columns C on C.object_id=O.object_id 
	left outer join sys.indexes I on I.object_id=O.object_id and I.is_primary_key=1
	left outer join sys.index_columns Y ON Y.object_id = I.object_id AND Y.index_id = I.index_id AND Y.column_id = C.column_id
	where QUOTENAME(S.name)+'.'+QUOTENAME(O.name) = DSQLT.QuoteNameSB(@Object)
	order by C.column_id
RETURN
END