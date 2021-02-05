

CREATE FUNCTION [DSQLT].[AllColumns]
(@Pattern NVARCHAR (MAX)='')
RETURNS @Result TABLE (
	[Name] [sysname] NOT NULL,
	[NameQ] [nvarchar](max) NOT NULL,
	[Column] [sysname] NOT NULL,
	[ColumnQ] [nvarchar](max) NOT NULL,
	[ObjectColumn] [nvarchar](max) NOT NULL,
	[ObjectColumnQ] [nvarchar](max) NOT NULL,
	[SchemaObjectColumn] [nvarchar](max) NOT NULL,
	[SchemaObjectColumnQ] [nvarchar](max) NOT NULL,
	[SchemaObject] [nvarchar](max) NOT NULL,
	[SchemaObjectQ] [nvarchar](max) NOT NULL,
	[Object] [nvarchar](max) NOT NULL,
	[ObjectQ] [nvarchar](max) NOT NULL,
	[Schema] [nvarchar](max) NOT NULL,
	[SchemaQ] [nvarchar](max) NOT NULL,
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
with ColumnList as
(
select 
	C.[Name] as [Name]
	,QUOTENAME(C.name) as NameQ
	,O.name as [Object]
	,QUOTENAME(O.name) as [ObjectQ] 
	,S.name as [Schema]
	,QUOTENAME(S.name) as [SchemaQ] 
    ,TYPE_NAME(c.user_type_id) AS [Type] 
    ,c.user_type_id AS [Type_Id] 
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
)
INSERT @Result
select top 100 percent
[Name]
,NameQ
,[Name] as [Column]
,NameQ as ColumnQ
,[Object]+'.'+[Name] as ObjectColumn
,[ObjectQ]+'.'+[NameQ] as ObjectColumnQ
,[Schema]+'.'+[Object]+'.'+[Name] as SchemaObjectColumn
,[SchemaQ]+'.'+[ObjectQ]+'.'+[NameQ] as SchemaObjectColumnQ
,[Schema]+'.'+[Object] as SchemaObject
,[SchemaQ]+'.'+[ObjectQ] as SchemaObjectQ
,[Object]
,[ObjectQ] 
,[Schema]
,[SchemaQ] 
,[Type] 
,[Type_Id] 
,is_primary_key
,is_nullable
,[Length]
,[Precision]
,[Scale]
,[Order]
from ColumnList
WHERE ([Schema]+'.'+[Object] LIKE @Pattern or [SchemaQ]+'.'+[ObjectQ] LIKE @Pattern)
order by [Schema],[Object],[Order]
RETURN
END