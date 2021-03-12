CREATE PROCEDURE ##Set_ExtendedProperties
AS
-- =========================================
-- Add Extended Properties to Object Template
-- =========================================
DECLARE @level0type NVARCHAR(128) = N'SCHEMA'
DECLARE @level1type NVARCHAR(128) = N'VIEW'

-- Add description to table object
--EXEC sys.sp_addextendedproperty 
--	@name=N'Owner',			@value=N'Ansa Bosch' ,
--	@level0type=N'SCHEMA',	@level0name=N'dbo', 
--	@level1type=N'VIEW',	@level1name=N'vw_DimEventType'
--GO

-- Can also use sp_updateextendedproperty or sp_dropextendedproperty
-- Checks if schema exists 
IF NOT EXISTS (SELECT 1 FROM sys.schemas AS sch WHERE sch.name = @level0name)
BEGIN
	SET @sql_message = N'The schema name ' + QUOTENAME(@schemaName} + ' does not exists!'
	RAISERROR(@sql_message, 500001 ,1) WITH NOWAIT
END

-- Check if object does exist 
-- TODO now we assuming its a VIEW but need to use the @level1type to figure that out
IF NOT EXISTS (SELECT 1 FROM sys.objects AS obj WHERE obj.name = @level1name)
BEGIN
	SET @sql_message = N'The schema name ' + QUOTENAME(@schemaName} + ' does not exists!'
	RAISERROR(@sql_message, 500001 ,1) WITH NOWAIT
END

-- Now check if teh extended property does exist
-- Here we will handle it differently though
--		EXISTS: Do update
--		NOT EXITS: Do Insert
--	Only for minor_id = 0 (thus tables/views/procs/functions)
IF NOT EXISTS (
				SELECT 1 FROM 
					sys.extended_properties AS ept 
					INNER JOIN sys.objects AS obj ON obj.object_id = ept.major_id 
					INNER JOIN sys.schemas AS sch ON sch.schema_id = obj.schema_id
					WHERE minor_id = 0
					AND sch.name = @level0name
					AND o.name= @level1name
)
-- INSERT PORTION
BEGIN

	EXEC sys.sp_addextendedproperty 
		@name=N'Description',		@value=N'Test2 this checks for overwrite' ,
		@level0type=@level0type,	@level0name=N'dbo', 
		@level1type=@level1type,	@level1name=N'vw_DimLeaveTypes'

END
ELSE
-- UPDATE PORTION
BEGIN



END





GO
