SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION managed_backup.fn_get_current_xevent_settings()
	RETURNS  @t TABLE(
		event_name	NVARCHAR(128),
		is_configurable	NVARCHAR(128),
		is_enabled	NVARCHAR(128)
		)
AS
BEGIN
DECLARE @XEventNames TABLE
	(
	event_name NVARCHAR(128),
	configurable NVARCHAR(128)
	)

	INSERT INTO @t VALUES ('SSMBackup2WAAdminXevent', 'false', 'true')
	INSERT INTO @t VALUES ('SSMBackup2WAOperationalXevent', 'false', 'true')
	INSERT INTO @t VALUES ('SSMBackup2WAAnalyticXevent', 'false', 'true')
	INSERT INTO @t VALUES ('FileRetentionAdminXevent', 'false', 'true')
	INSERT INTO @t VALUES ('FileRetentionAnalyticXevent', 'false', 'true')
	INSERT INTO @XEventNames VALUES ('SSMBackup2WADebugXevent', 'true')
	INSERT INTO @XEventNames VALUES ('FileRetentionOperationalXevent', 'true')
	INSERT INTO @XEventNames VALUES ('FileRetentionDebugXevent', 'true')
	INSERT INTO @XEventNames VALUES ('StorageOperationDebugXevent', 'true')
	
	INSERT INTO @t
	SELECT event_name, configurable,
	CASE  WHEN value IS NULL THEN 'false' ELSE value END AS IsEnabled
	FROM
	(
		SELECT *
		FROM @XEventNames t1 LEFT JOIN
	     autoadmin_system_flags t2 ON t1.event_name = t2.name
	) t
	RETURN
END

GO
