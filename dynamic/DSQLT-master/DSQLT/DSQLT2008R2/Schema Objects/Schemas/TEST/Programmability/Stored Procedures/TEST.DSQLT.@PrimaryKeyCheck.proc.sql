


CREATE Proc [TEST].[DSQLT.@PrimaryKeyCheck]
as
DECLARE	@return_value int

EXEC	@return_value = [DSQLT].[@PrimaryKeyCheck]
		@SourceSchema = Sample,
		@SourceTable = Source_Product,
		@PrimaryKeySchema = Sample,
		@PrimaryKeyTable = Target_Product,
		@Create = N'Sample.PrimaryKeyCheck_Product',
		@Print = 0

SELECT	'Return Value' = @return_value