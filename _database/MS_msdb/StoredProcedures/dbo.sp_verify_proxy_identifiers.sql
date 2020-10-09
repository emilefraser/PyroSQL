SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_verify_proxy_identifiers
   @name_of_name_parameter [varchar](60),
   @name_of_id_parameter [varchar](60),
   @proxy_name [sysname] OUTPUT,
   @proxy_id [INT] OUTPUT
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @proxy_id_as_char NVARCHAR(36)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name_of_name_parameter = LTRIM(RTRIM(@name_of_name_parameter))
  SELECT @name_of_id_parameter   = LTRIM(RTRIM(@name_of_id_parameter))
  SELECT @proxy_name             = LTRIM(RTRIM(@proxy_name))

  IF (@proxy_name = N'') SELECT @proxy_name = NULL

  IF ((@proxy_name IS NULL)     AND (@proxy_id IS NULL)) OR
     ((@proxy_name IS NOT NULL) AND (@proxy_id IS NOT NULL))
  BEGIN
    RAISERROR(14524, -1, -1, @name_of_id_parameter, @name_of_name_parameter)
    RETURN(1) -- Failure
  END

  -- Check proxy id
  IF (@proxy_id IS NOT NULL)
  BEGIN
    SELECT @proxy_name = name
    FROM msdb.dbo.sysproxies
    WHERE (proxy_id = @proxy_id)
    IF (@proxy_name IS NULL)
    BEGIN
     SELECT @proxy_id_as_char = CONVERT(nvarchar(36), @proxy_id)
      RAISERROR(14262, -1, -1, @name_of_id_parameter, @proxy_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
  -- Check proxy name
  IF (@proxy_name IS NOT NULL)
  BEGIN
    -- The name is not ambiguous, so get the corresponding proxy_id (if the job exists)
    SELECT @proxy_id = proxy_id
    FROM msdb.dbo.sysproxies
    WHERE (name = @proxy_name)
    IF (@proxy_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, @name_of_name_parameter, @proxy_name)
      RETURN(1) -- Failure
    END
  END

  RETURN(0) -- Success
END

GO
