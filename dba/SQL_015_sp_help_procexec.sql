USE master;

GO

IF Object_id('[dbo].[sp_help_procexec]') IS NOT NULL
  DROP PROCEDURE [dbo].[sp_help_procexec]

GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: counts how many time sthe passed in proc was executed fromt he cached_plans
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_help_procexec](@procname SYSNAME = NULL)
AS
    DECLARE @ServerRestartedDate VARCHAR(30)

    SELECT @ServerRestartedDate = CONVERT(VARCHAR(30), dbz.create_date, 120)
    FROM   sys.databases dbz
    WHERE  NAME = 'tempdb'

    SELECT @ServerRestartedDate                         AS ServerRestartedDate,
           Db_name(stxt.dbid)                           dbname,
           Object_schema_name(stxt.objectid, stxt.dbid) schemaname,
           Object_name(stxt.objectid, stxt.dbid)        storedprocedure,
           Max(cp.usecounts)                            execution_count,
           Max(LastElapsedSeconds)                      AS LastElapsedSeconds,
           Max(MaxElapsedSeconds)                       AS MaxElapsedSeconds,
           Max(LastExecutionTime)                       AS LastExecutionTime,
           Max(TotalExecutions)                         AS TotalExecutions
    --select *
    FROM   sys.dm_exec_cached_plans cp
           CROSS APPLY sys.Dm_exec_sql_text(cp.plan_handle) stxt
           INNER JOIN (SELECT st.last_execution_time                   AS LastExecutionTime,
                              st.execution_count                       AS TotalExecutions,
                              ( st.last_elapsed_time / 1000000 )       AS LastElapsedSeconds,
                              ( st.max_elapsed_time / 1000000 )        AS MaxElapsedSeconds,
                              Db_name(fn.dbid)                         AS dbname,
                              Object_schema_name(fn.objectid, fn.dbid) AS schemaname,
                              Object_name(fn.objectid, fn.dbid)        AS objectname,
                              fn.*,
                              st.*
                       FROM   sys.dm_exec_query_stats st
                              CROSS APPLY sys.Dm_exec_sql_text(st.[sql_handle]) fn) statz
                   ON stxt.objectid = statz.objectid
                      AND stxt.dbid = statz.dbid
    WHERE  Db_name(stxt.dbid) IS NOT NULL
           AND Db_name(stxt.dbid) = Db_name()
           AND cp.objtype = 'proc'
           AND ( stxt.objectid = Object_id(@procname)
                  OR @procname IS NULL )
    GROUP  BY cp.plan_handle,
              Db_name(stxt.dbid),
              Object_schema_name(stxt.objectid, stxt.dbid),
              Object_name(stxt.objectid, stxt.dbid)
    ORDER  BY Max(cp.usecounts)

GO

--#################################################################################################
--Mark as a system object
EXECUTE Sp_ms_marksystemobject
  '[dbo].[Sp_help_procexec]'
--#################################################################################################
