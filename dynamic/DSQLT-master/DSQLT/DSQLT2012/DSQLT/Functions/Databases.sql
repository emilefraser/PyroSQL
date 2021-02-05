CREATE FUNCTION [DSQLT].[Databases]
(@Pattern NVARCHAR (MAX)='')
RETURNS TABLE 
AS
RETURN 
    (
select 
S.name as [Database]
,QUOTENAME(S.name) as DatabaseQ
from sys.databases S 
where S.name LIKE @Pattern
or  QUOTENAME(S.name) LIKE @Pattern)
