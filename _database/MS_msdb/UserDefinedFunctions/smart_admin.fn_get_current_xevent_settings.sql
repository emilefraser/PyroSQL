SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION smart_admin.fn_get_current_xevent_settings()
	RETURNS  @t TABLE(
		event_name	NVARCHAR(128),
		is_configurable	NVARCHAR(128),
		is_enabled	NVARCHAR(128)
		)
AS
BEGIN
	INSERT INTO @t
	SELECT event_name, is_configurable, is_enabled
	FROM managed_backup.fn_get_current_xevent_settings()

	RETURN
END

GO
