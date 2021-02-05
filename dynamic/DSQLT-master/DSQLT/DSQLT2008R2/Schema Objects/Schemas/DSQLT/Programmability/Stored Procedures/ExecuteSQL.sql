
CREATE PROCEDURE [DSQLT].[ExecuteSQL]
@SQL NVARCHAR (MAX)
, @Database [sysname]=null
, @Print BIT=0
AS
BEGIN
SET NOCOUNT ON
exec DSQLT._doTemplate @Database,@SQL,@Print
RETURN 0
END