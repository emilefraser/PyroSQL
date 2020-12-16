--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: Creates an Extended Event that captures NetworkWaits occurring on the server,
--#################################################################################################
IF NOT EXISTS(SELECT * FROM [sys].[server_event_sessions] AS [dxs] WHERE [dxs].[name] = 'NetworkWaits')
  BEGIN
    CREATE EVENT SESSION [NetworkWaits] ON SERVER 
        ADD EVENT sqlos.wait_info_external(
            ACTION(package0.collect_system_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.server_instance_name,sqlserver.server_principal_name,sqlserver.server_principal_sid,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username))
        ADD TARGET package0.event_file(SET filename=N'NetworkWaits',max_file_size=(50),max_rollover_files=(2))
            WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
END
--ALTER EVENT SESSION [NetworkWaits] ON SERVER STATE = START
--ALTER EVENT SESSION [NetworkWaits] ON SERVER STATE = STOP
