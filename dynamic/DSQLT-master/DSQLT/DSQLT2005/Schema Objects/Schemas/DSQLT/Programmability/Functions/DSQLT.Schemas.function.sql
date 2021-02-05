--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	List of Schemas
--
--------------------------------------------------------
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
