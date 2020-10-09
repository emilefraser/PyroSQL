SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_delete_maintenance_plan_db
  @plan_id uniqueidentifier,
  @db_name sysname
AS
BEGIN
  /*check if the (plan_id, db_name) exists in the table*/
  IF (NOT EXISTS(SELECT *
                 FROM msdb.dbo.sysdbmaintplan_databases
                 WHERE @plan_id=plan_id AND @db_name=database_name))
  BEGIN
    DECLARE @syserr VARCHAR(300)
    SELECT @syserr=CONVERT(VARCHAR(100),@plan_id)+' + '+@db_name
    RAISERROR(14262,-1,-1,'@plan_id+@db_name',@syserr)
    RETURN(1)
  END
  /*delete the pair*/
  DELETE FROM msdb.dbo.sysdbmaintplan_databases
  WHERE plan_id=@plan_id AND database_name=@db_name
END

GO
