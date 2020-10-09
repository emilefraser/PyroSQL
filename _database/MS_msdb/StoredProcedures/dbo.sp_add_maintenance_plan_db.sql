SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_add_maintenance_plan_db
  @plan_id UNIQUEIDENTIFIER,
  @db_name sysname
AS
BEGIN
  DECLARE @syserr VARCHAR(100)
  /*check if the plan_id is valid */
  IF (NOT EXISTS (SELECT plan_id
              FROM  msdb.dbo.sysdbmaintplans
              WHERE plan_id=@plan_id))
  BEGIN
    SELECT @syserr=CONVERT(VARCHAR(100),@plan_id)
    RAISERROR(14262,-1,-1,'@plan_id',@syserr)
    RETURN(1)
  END
  /*check if the database name is valid */
  IF (NOT EXISTS (SELECT name
              FROM master.dbo.sysdatabases
              WHERE name=@db_name))
   BEGIN
    RAISERROR(14262,-1,-1,'@db_name',@db_name)
    RETURN(1)
  END
  /*check if the (plan_id, database) pair already exists*/
  IF (EXISTS (SELECT *
              FROM sysdbmaintplan_databases
              WHERE plan_id=@plan_id AND database_name=@db_name))
  BEGIN
    SELECT @syserr=CONVERT(VARCHAR(100),@plan_id)+' + '+@db_name
    RAISERROR(14261,-1,-1,'@plan_id+@db_name',@syserr)
    RETURN(1)
  END
  INSERT INTO msdb.dbo.sysdbmaintplan_databases (plan_id,database_name) VALUES (@plan_id, @db_name)
END

GO
