SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE VIEW sysalerts_performance_counters_view
AS
    -- Parse object_name 'SQLServer:Buffer Manager', exclude instance specific info; return as 'Buffer Manager'
    SELECT RTRIM(SUBSTRING(pc.object_name, CHARINDEX(':', pc.object_name)+1, DATALENGTH(pc.object_name))) AS 'object_name',
            RTRIM(pc.counter_name) AS 'counter_name',
            CASE WHEN pc.instance_name IS NULL
                THEN NULL
                ELSE RTRIM(pc.instance_name)
            END AS 'instance_name',
            pc.cntr_value,
            pc.cntr_type,
            SERVERPROPERTY('ServerName') AS 'server_name'
    FROM sys.dm_os_performance_counters pc

GO
