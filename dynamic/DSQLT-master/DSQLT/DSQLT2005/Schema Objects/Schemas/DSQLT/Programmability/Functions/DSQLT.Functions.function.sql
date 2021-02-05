--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	List of Functions
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[Functions]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name+'.'+O.name as SchemaFunction
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaFunctionQ
,S.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,O.name as [Function] 
,QUOTENAME(O.name) as [FunctionQ] 
from sys.objects O
join sys.schemas S on O.schema_id=S.schema_id
WHERE type in (N'AF',N'FN',N'FS',N'FT',N'IF',N'TF')
and (	S.name+'.'+O.name LIKE @Pattern
	or  QUOTENAME(S.name)+'.'+QUOTENAME(O.name) LIKE @Pattern)
)

