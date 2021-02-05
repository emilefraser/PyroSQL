CREATE proc [TEST].[DSQLT.@SyncTable] as
DECLARE	@return_value int

EXEC	@return_value = [DSQLT].[@SyncTable]
		@SourceSchema = sample,
		@SourceTable = source_product,
		@TargetSchema = sample,
		@TargetTable = target_product,
		@PrimaryKeySchema = NULL,
		@PrimaryKeyTable = NULL,
		@IgnoreColumnList = '',
		@UseDefaultValues = NULL,
		@Create = NULL,
		@Print = 1

SELECT	'Return Value' = @return_value
