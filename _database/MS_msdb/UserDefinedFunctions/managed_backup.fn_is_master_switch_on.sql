SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Returns the present state of the Smart Admin master switch.
-- 1 = ON, 0 = OFF. When the switch is OFF, all Smart Admin services are paused.
--
CREATE FUNCTION managed_backup.fn_is_master_switch_on () 
	RETURNS BIT
AS
BEGIN
	DECLARE @state BIT
	
	SELECT 	@state = [state] FROM autoadmin_master_switch
	
	IF @state IS NULL
	BEGIN
		SET @state = 1
	END

	RETURN @state
END

GO
