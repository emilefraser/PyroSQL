SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- Returns the present state of the Smart Admin master switch.
-- 1 = ON, 0 = OFF. When the switch is OFF, all Smart Admin services are paused.
--
CREATE FUNCTION smart_admin.fn_is_master_switch_on () 
	RETURNS BIT
AS
BEGIN
	DECLARE @state BIT
	
	EXEC @state = [managed_backup].[fn_is_master_switch_on]
	
	RETURN @state
END

GO
