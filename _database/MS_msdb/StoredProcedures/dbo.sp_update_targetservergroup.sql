SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_update_targetservergroup
  @name     sysname,
  @new_name sysname
AS
BEGIN
  SET NOCOUNT ON

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @name     = LTRIM(RTRIM(@name))
  SELECT @new_name = LTRIM(RTRIM(@new_name))

  -- Check if the group exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.systargetservergroups
                  WHERE (name = @name)))
  BEGIN
    RAISERROR(14262, -1, -1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Check if a group with the new name already exists
  IF (EXISTS (SELECT *
              FROM msdb.dbo.systargetservergroups
              WHERE (name = @new_name)))
  BEGIN
    RAISERROR(14261, -1, -1, '@new_name', @new_name)
    RETURN(1) -- Failure
  END

  -- Disallow names with commas in them (since sp_apply_job_to_targets parses a comma-separated list of group names)
  IF (@new_name LIKE N'%,%')
  BEGIN
    RAISERROR(14289, -1, -1, '@new_name', ',')
    RETURN(1) -- Failure
  END

  -- Update the group's name
  UPDATE msdb.dbo.systargetservergroups
  SET name = @new_name
  WHERE (name = @name)

  RETURN(@@error) -- 0 means success
END

GO
