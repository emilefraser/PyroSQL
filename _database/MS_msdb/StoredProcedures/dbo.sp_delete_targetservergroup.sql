SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_delete_targetservergroup
  @name sysname
AS
BEGIN
  DECLARE @servergroup_id INT

  SET NOCOUNT ON

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @name = LTRIM(RTRIM(@name))

  -- Check if the group exists
  SELECT @servergroup_id = servergroup_id
  FROM msdb.dbo.systargetservergroups
  WHERE (name = @name)

  IF (@servergroup_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Remove the group members
  DELETE FROM msdb.dbo.systargetservergroupmembers
  WHERE (servergroup_id = @servergroup_id)

  -- Remove the group
  DELETE FROM msdb.dbo.systargetservergroups
  WHERE (name = @name)

  RETURN(@@error) -- 0 means success
END

GO
