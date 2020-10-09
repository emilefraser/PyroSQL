SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_maintplan_update_subplan
    @subplan_id       UNIQUEIDENTIFIER,
    @plan_id       UNIQUEIDENTIFIER    = NULL,
    @name          sysname             = NULL,
    @description  NVARCHAR(512)       = NULL,
    @job_id        UNIQUEIDENTIFIER    = NULL,
    @schedule_id  INT                 = NULL,
    @allow_create   BIT                 = 0,
    @msx_job_id    UNIQUEIDENTIFIER    = NULL
AS
BEGIN

   SET NOCOUNT ON

   SELECT @name = LTRIM(RTRIM(@name))
   SELECT @description = LTRIM(RTRIM(@description))

   --Are we creating a new entry or updating an existing one?

   IF( NOT EXISTS(SELECT * FROM msdb.dbo.sysmaintplan_subplans WHERE subplan_id = @subplan_id) )
   BEGIN
        -- Only allow creation of a record if user permits it
        IF(@allow_create = 0)
        BEGIN
            DECLARE @subplan_id_as_char VARCHAR(36)
            SELECT @subplan_id_as_char = CONVERT(VARCHAR(36), @subplan_id)
            RAISERROR(14262, -1, -1, '@subplan_id', @subplan_id_as_char)
          RETURN(1)
        END

        --Insert it's a new subplan
      IF (@name IS NULL)
      BEGIN
          RAISERROR(12981, -1, -1, '@name')
         RETURN(1) -- Failure
      END

      IF (@plan_id IS NULL)
      BEGIN
          RAISERROR(12981, -1, -1, '@plan_id')
         RETURN(1) -- Failure
      END

      INSERT INTO msdb.dbo.sysmaintplan_subplans(
            subplan_id,
            plan_id,
            subplan_description,
            subplan_name,
            job_id,
            schedule_id,
            msx_job_id)
      VALUES(
            @subplan_id,
            @plan_id,
            @description,
            @name,
            @job_id,
            @schedule_id,
            @msx_job_id)

   END
   ELSE
   BEGIN --Update the table

      DECLARE @s_subplan_name sysname
      DECLARE @s_job_id UNIQUEIDENTIFIER

      SELECT @s_subplan_name         = subplan_name,
            @s_job_id               = job_id
      FROM msdb.dbo.sysmaintplan_subplans
      WHERE (@subplan_id = subplan_id)

      --Determine if user wants to change these variables
      IF (@name IS NOT NULL)          SELECT @s_subplan_name          = @name
      IF (@job_id IS NOT NULL)        SELECT @s_job_id                = @job_id

      --UPDATE the record

      UPDATE msdb.dbo.sysmaintplan_subplans 
        SET subplan_name        = @s_subplan_name,
            subplan_description = @description,
            job_id              = @s_job_id,
            schedule_id         = @schedule_id,
            msx_job_id          = @msx_job_id
      WHERE (subplan_id = @subplan_id)

   END

    RETURN (@@ERROR)
END

GO
