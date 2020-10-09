SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_clear_dbmaintplan_by_db
  @db_name sysname
AS
BEGIN
  DECLARE planid_cursor CURSOR
  FOR
  select plan_id from msdb.dbo.sysdbmaintplan_databases where database_name=@db_name
  OPEN planid_cursor
  declare @planid uniqueidentifier
  FETCH NEXT FROM planid_cursor INTO @planid
  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
    IF (@@FETCH_STATUS <> -2)
    BEGIN
      delete from msdb.dbo.sysdbmaintplan_databases where plan_id=@planid AND database_name=@db_name
      if (NOT EXISTS(select * from msdb.dbo.sysdbmaintplan_databases where plan_id=@planid))
      BEGIN
        --delete the job
        DECLARE jobid_cursor CURSOR
        FOR
        select job_id from msdb.dbo.sysdbmaintplan_jobs where plan_id=@planid
        OPEN jobid_cursor
        DECLARE @jobid uniqueidentifier
        FETCH NEXT FROM jobid_cursor INTO @jobid
        WHILE (@@FETCH_STATUS <> -1)
        BEGIN
          if (@@FETCH_STATUS <> -2)
          BEGIN
            execute msdb.dbo.sp_delete_job @jobid
          END
          FETCH NEXT FROM jobid_cursor into @jobid
        END
        CLOSE jobid_cursor
        DEALLOCATE jobid_cursor
        --delete the history
        delete from msdb.dbo.sysdbmaintplan_history where plan_id=@planid
        --delete the plan
        delete from msdb.dbo.sysdbmaintplans where plan_id=@planid
      END
    END
    FETCH NEXT FROM planid_cursor INTO @planid
  END
  CLOSE planid_cursor
  DEALLOCATE planid_cursor
END

GO
