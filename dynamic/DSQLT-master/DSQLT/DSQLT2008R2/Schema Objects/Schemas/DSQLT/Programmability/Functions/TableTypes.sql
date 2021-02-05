

CREATE FUNCTION [DSQLT].[TableTypes]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.[Name]+'.'+O.[Name] as SchemaTableType
,QUOTENAME(S.[Name])+'.'+QUOTENAME(O.[Name]) as SchemaTableTypeQ
,S.[Name] as [Schema]
,QUOTENAME(S.[Name]) as [SchemaQ]
,O.[Name] as [TableType] 
,QUOTENAME(O.[Name]) as [TableTypeQ] 
from sys.types O
join sys.schemas S on O.schema_id=S.schema_id
WHERE O.is_table_type=1 and 
(	S.[Name]+'.'+O.[Name] LIKE @Pattern
	or  QUOTENAME(S.[Name])+'.'+QUOTENAME(O.[Name]) LIKE @Pattern)
)