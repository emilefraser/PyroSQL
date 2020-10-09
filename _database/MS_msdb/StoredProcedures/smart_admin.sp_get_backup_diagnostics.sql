SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE smart_admin.sp_get_backup_diagnostics
	@xevent_channel VARCHAR(255) = 'Xevent',
	@begin_time DATETIME = NULL,
	@end_time DATETIME = NULL
AS
BEGIN
	EXECUTE managed_backup.sp_get_backup_diagnostics @xevent_channel, @begin_time, @end_time
END


GO
