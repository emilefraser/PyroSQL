
CREATE FUNCTION [DSQLT].[Schemas]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name as [Schema]
,QUOTENAME(S.name) as SchemaQ
from sys.schemas S 
WHERE (	S.name LIKE @Pattern
	or  QUOTENAME(S.name) LIKE @Pattern)
)
