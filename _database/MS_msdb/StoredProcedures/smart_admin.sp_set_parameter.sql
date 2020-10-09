SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- Set the value of an internal system flag. These values govern the behavior of smart-backup algorithms.
--
CREATE PROCEDURE smart_admin.sp_set_parameter
	@parameter_name NVARCHAR(128),
	@parameter_value NVARCHAR(128)
AS
BEGIN
	EXECUTE managed_backup.sp_set_parameter @parameter_name, @parameter_value
END


GO
