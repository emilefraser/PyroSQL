
CREATE FUNCTION [DSQLT].[Synonyms]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name+'.'+O.name as SchemaSynonym
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaSynonymQ
,S.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,O.name as [Synonym] 
,QUOTENAME(O.name) as [SynonymQ] 
,O.base_object_name
,Parsename(O.base_object_name,4) as [Object_Server]
,Parsename(O.base_object_name,3) as [Object_Database]
,Parsename(O.base_object_name,2) as [Object_Schema]
,Parsename(O.base_object_name,1) as [Object_Name]
,QUOTENAME(Parsename(O.base_object_name,4)) as [Object_ServerQ]
,QUOTENAME(Parsename(O.base_object_name,3)) as [Object_DatabaseQ]
,QUOTENAME(Parsename(O.base_object_name,2)) as [Object_SchemaQ]
,QUOTENAME(Parsename(O.base_object_name,1)) as [Object_NameQ]
from sys.synonyms O
join sys.schemas S on O.schema_id=S.schema_id
WHERE type in (N'SN')
and (	S.name+'.'+O.name LIKE @Pattern
	or  QUOTENAME(S.name)+'.'+QUOTENAME(O.name) LIKE @Pattern)
)