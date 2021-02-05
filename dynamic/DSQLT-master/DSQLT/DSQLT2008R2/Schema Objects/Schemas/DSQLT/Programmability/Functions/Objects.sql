CREATE FUNCTION [DSQLT].[Objects]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name+'.'+O.name as SchemaObject
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaObjectQ
,S.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,O.name as [Object] 
,QUOTENAME(O.name) as [ObjectQ] 
,O.type as Object_Type
from sys.objects O
join sys.schemas S on O.schema_id=S.schema_id
and (	S.name+'.'+O.name LIKE @Pattern
	or  QUOTENAME(S.name)+'.'+QUOTENAME(O.name) LIKE @Pattern)
UNION 
SELECT *, 'TT' from [DSQLT].[TableTypes](@Pattern)
)