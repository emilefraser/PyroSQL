SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_verify_operator_identifiers
   @name_of_name_parameter [varchar](60),
   @name_of_id_parameter [varchar](60),
   @operator_name [sysname] OUTPUT,
   @operator_id [INT] OUTPUT
AS
BEGIN
  DECLARE @retval              INT
  DECLARE @operator_id_as_char NVARCHAR(36)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name_of_name_parameter = LTRIM(RTRIM(@name_of_name_parameter))
  SELECT @name_of_id_parameter   = LTRIM(RTRIM(@name_of_id_parameter))
  SELECT @operator_name             = LTRIM(RTRIM(@operator_name))

  IF (@operator_name = N'') SELECT @operator_name = NULL

  IF ((@operator_name IS NULL)     AND (@operator_id IS NULL)) OR
     ((@operator_name IS NOT NULL) AND (@operator_id IS NOT NULL))
  BEGIN
    RAISERROR(14524, -1, -1, @name_of_id_parameter, @name_of_name_parameter)
    RETURN(1) -- Failure
  END

  -- Check job id
  IF (@operator_id IS NOT NULL)
  BEGIN
    SELECT @operator_name = name
    FROM msdb.dbo.sysoperators
    WHERE (id = @operator_id)
    IF (@operator_name IS NULL)
    BEGIN
     SELECT @operator_id_as_char = CONVERT(nvarchar(36), @operator_id)
      RAISERROR(14262, -1, -1, '@operator_id', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
  -- Check proxy name
  IF (@operator_name IS NOT NULL)
  BEGIN
    -- The name is not ambiguous, so get the corresponding operator_id (if the job exists)
    SELECT @operator_id = id
    FROM msdb.dbo.sysoperators
    WHERE (name = @operator_name)
    IF (@operator_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@operator_name', @operator_name)
      RETURN(1) -- Failure
    END
  END

  RETURN(0) -- Success
END

GO
