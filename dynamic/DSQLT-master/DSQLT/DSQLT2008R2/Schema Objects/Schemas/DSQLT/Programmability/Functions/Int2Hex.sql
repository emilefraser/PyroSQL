CREATE FUNCTION DSQLT.Int2Hex
(
@intvalue int
)
RETURNS varchar(256)
as
BEGIN
declare @binvalue varbinary(256)
set @binvalue=convert(varbinary(8),@intvalue)
return DSQLT.Bin2Hex(@binvalue)
end