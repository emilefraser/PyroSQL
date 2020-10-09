SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_verify_category_identifiers
   @name_of_name_parameter [varchar](60),
   @name_of_id_parameter [varchar](60),
   @category_name [sysname] OUTPUT,
   @category_id [INT] OUTPUT
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @category_id_as_char NVARCHAR(36)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name_of_name_parameter = LTRIM(RTRIM(@name_of_name_parameter))
  SELECT @name_of_id_parameter   = LTRIM(RTRIM(@name_of_id_parameter))
  SELECT @category_name          = LTRIM(RTRIM(@category_name))

  IF (@category_name = N'') SELECT @category_name = NULL

  IF ((@category_name IS NOT NULL) AND (@category_id IS NOT NULL))
  BEGIN
    RAISERROR(14524, -1, -1, @name_of_id_parameter, @name_of_name_parameter)
    RETURN(1) -- Failure
  END

  -- Check category id
  IF (@category_id IS NOT NULL)
  BEGIN
    SELECT @category_name = name
    FROM msdb.dbo.syscategories
    WHERE (category_id = @category_id)
    IF (@category_name IS NULL)
    BEGIN
     SELECT @category_id_as_char = CONVERT(nvarchar(36), @category_id)
      RAISERROR(14262, -1, -1, '@category_id', @category_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
  -- Check category name
  IF (@category_name IS NOT NULL)
  BEGIN
    -- The name is not ambiguous, so get the corresponding category_id (if the job exists)
    SELECT @category_id = category_id
    FROM msdb.dbo.syscategories
    WHERE (name = @category_name)
    IF (@category_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@category_name', @category_name)
      RETURN(1) -- Failure
    END
  END

  RETURN(0) -- Success
END

GO
