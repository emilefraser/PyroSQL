



CREATE PROC [Sample].[@Test] 
AS
RETURN
BEGIN
select 
S.name+'.'+O.name as SchemaTable
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaTableQ
,S.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,O.name as [Table] 
,QUOTENAME(O.name) as [TableQ] 
from sys.tables O
join sys.schemas S on O.schema_id=S.schema_id
WHERE (	S.name+'.'+O.name LIKE '%@1%'
	or  QUOTENAME(S.name)+'.'+QUOTENAME(O.name) LIKE '%@1%')
END







