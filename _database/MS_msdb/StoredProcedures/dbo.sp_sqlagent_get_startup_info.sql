SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_sqlagent_get_startup_info
AS
BEGIN
  DECLARE @tbu INT
  DECLARE @agentAllowed INT

  SET NOCOUNT ON

  IF (ServerProperty('InstanceName') IS NULL)
  BEGIN
    EXECUTE @tbu = master.dbo.xp_qv '1338198028'
    EXECUTE @agentAllowed = master.dbo.xp_qv '2858542058'
  END
  ELSE
  BEGIN
    DECLARE @instancename NVARCHAR(128)
    SELECT @instancename = CONVERT(NVARCHAR(128), ServerProperty('InstanceName'))
    EXECUTE @tbu = master.dbo.xp_qv '1338198028', @instancename
    EXECUTE @agentAllowed = master.dbo.xp_qv '2858542058', @instancename
  END

  IF (@tbu < 0)
    SELECT @tbu = 0

  IF (@agentAllowed < 0)
    SELECT @agentAllowed = 0

  SELECT ( CASE WHEN DATABASEPROPERTYEX('msdb', 'Updateability') = 'READ_ONLY'
                THEN 1
                ELSE 0
           END )  AS msdb_read_only,
         ( CASE WHEN DATABASEPROPERTYEX('msdb', 'Status') = 'ONLINE' THEN 1 ELSE 0 END  &
           CASE WHEN DATABASEPROPERTYEX('msdb', 'UserAccess') = 'MULTI_USER' THEN 1 ELSE 0 END)  AS msdb_available,
         CASE ISNULL((SELECT 1 WHERE 'a' = 'A'), 0)
             WHEN 1 THEN 0
             ELSE 1
         END AS case_sensitive_server,
         (SELECT value_in_use FROM sys.configurations WHERE (name = 'user connections')) AS max_user_connection,
         CONVERT(sysname, SERVERPROPERTY('SERVERNAME')) AS sql_server_name,
         ISNULL(@tbu, 0) AS tbu,
         PLATFORM() AS platform,
         ISNULL(CONVERT(sysname, SERVERPROPERTY('INSTANCENAME')), 'MSSQLSERVER') AS instance_name ,
         CONVERT(INT, SERVERPROPERTY('ISCLUSTERED')) AS is_clustered,
         @agentAllowed AS agent_allowed

  RETURN(0) -- Success
END

GO
