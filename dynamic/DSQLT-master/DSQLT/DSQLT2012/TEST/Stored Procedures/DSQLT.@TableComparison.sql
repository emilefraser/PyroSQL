CREATE Proc [TEST].[DSQLT.@TableComparison]
as
DECLARE	@return_value int

EXEC	@return_value = [DSQLT].[@TableComparison]
		@SourceSchema = Sample,
		@SourceTable = Source_Product,
		@TargetSchema = Sample,
		@TargetTable = Target_Product,
		@PrimaryKeySchema = Sample,
		@PrimaryKeyTable = Target_Product,
		@Create = N'Sample.Compare_Product',
		@Print = 0

SELECT	'Return Value' = @return_value
