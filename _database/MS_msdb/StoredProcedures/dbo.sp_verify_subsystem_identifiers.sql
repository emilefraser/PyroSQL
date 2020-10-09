SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sp_verify_subsystem_identifiers
   @name_of_name_parameter [varchar](60),
   @name_of_id_parameter [varchar](60),
   @subsystem_name [sysname] OUTPUT,
   @subsystem_id [INT] OUTPUT
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @subsystem_id_as_char NVARCHAR(36)

  SET NOCOUNT ON

  -- this call will populate subsystems table if necessary
  EXEC @retval = msdb.dbo.sp_verify_subsystems
  IF @retval <> 0
     RETURN(@retval)

  -- Remove any leading/trailing spaces from parameters
  SELECT @name_of_name_parameter = LTRIM(RTRIM(@name_of_name_parameter))
  SELECT @name_of_id_parameter   = LTRIM(RTRIM(@name_of_id_parameter))
  SELECT @subsystem_name         = LTRIM(RTRIM(@subsystem_name))

  IF (@subsystem_name = N'') SELECT @subsystem_name = NULL

  IF ((@subsystem_name IS NULL)     AND (@subsystem_id IS NULL)) OR
     ((@subsystem_name IS NOT NULL) AND (@subsystem_id IS NOT NULL))
  BEGIN
    RAISERROR(14524, -1, -1, @name_of_id_parameter, @name_of_name_parameter)
    RETURN(1) -- Failure
  END

  -- Check subsystem_id
  IF (@subsystem_id IS NOT NULL)
  BEGIN
    SELECT @subsystem_name = subsystem
    FROM msdb.dbo.syssubsystems
    WHERE (subsystem_id = @subsystem_id)
    IF (@subsystem_name IS NULL)
    BEGIN
     SELECT @subsystem_id_as_char = CONVERT(nvarchar(36), @subsystem_id)
      RAISERROR(14262, -1, -1, '@subsystem_id', @subsystem_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
  -- Check subsystem name
  IF (@subsystem_name IS NOT NULL)
  BEGIN
    -- Make sure Dts is translated into new subsystem's name SSIS
    IF UPPER(@subsystem_name collate SQL_Latin1_General_CP1_CS_AS) = N'DTS'
    BEGIN
      SET @subsystem_name = N'SSIS'
    END

    -- The name is not ambiguous, so get the corresponding subsystem_id (if the subsystem exists)
    SELECT @subsystem_id = subsystem_id
    FROM msdb.dbo.syssubsystems
    WHERE (UPPER(subsystem collate SQL_Latin1_General_CP1_CS_AS) = UPPER(@subsystem_name collate SQL_Latin1_General_CP1_CS_AS))
    IF (@subsystem_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@subsystem_name', @subsystem_name)
      RETURN(1) -- Failure
    END
  END

  RETURN(0) -- Success
END

GO
