SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_add_maintenance_plan
  @plan_name varchar(128),
  @plan_id   UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
  IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysdbmaintplans
                WHERE plan_name=@plan_name))
    BEGIN
      SELECT @plan_id=NEWID()
      INSERT INTO msdb.dbo.sysdbmaintplans (plan_id, plan_name) VALUES (@plan_id, @plan_name)
    END
  ELSE
    BEGIN
      RAISERROR(14261,-1,-1,'@plan_name',@plan_name)
      RETURN(1) -- failure
    END
END

GO
