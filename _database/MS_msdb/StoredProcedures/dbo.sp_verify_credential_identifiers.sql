SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_verify_credential_identifiers
   @name_of_name_parameter [varchar](60),
   @name_of_id_parameter [varchar](60),
   @credential_name [sysname] OUTPUT,
   @credential_id [INT] OUTPUT,
   @allow_only_windows_credential bit = NULL
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @credential_id_as_char NVARCHAR(36)
  DECLARE @credential_identity NVARCHAR(4000)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name_of_name_parameter = LTRIM(RTRIM(@name_of_name_parameter))
  SELECT @name_of_id_parameter   = LTRIM(RTRIM(@name_of_id_parameter))
  SELECT @credential_name        = LTRIM(RTRIM(@credential_name))

  IF (@credential_name = N'') SELECT @credential_name = NULL

  IF ((@credential_name IS NULL)     AND (@credential_id IS NULL)) OR
     ((@credential_name IS NOT NULL) AND (@credential_id IS NOT NULL))
  BEGIN
    RAISERROR(14524, -1, -1, @name_of_id_parameter, @name_of_name_parameter)
    RETURN(1) -- Failure
  END

  -- Check credential_id
  IF (@credential_id IS NOT NULL)
  BEGIN
    SELECT @credential_name = name,
    @credential_identity = credential_identity
    FROM sys.credentials
    WHERE (credential_id = @credential_id)

    IF (@credential_name IS NULL)
    BEGIN
     SELECT @credential_id_as_char = CONVERT(nvarchar(36), @credential_id)
      RAISERROR(14262, -1, -1, '@credential_id', @credential_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
  -- Check credential name
  IF (@credential_name IS NOT NULL)
  BEGIN
      -- The name is not ambiguous, so get the corresponding credential_id (if the job exists)
    SELECT @credential_id = credential_id,
    @credential_identity = credential_identity
    FROM sys.credentials
    WHERE (name = @credential_name)

    IF (@credential_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@credential_name', @credential_name)
      RETURN(1) -- Failure
    END
  END

  IF(@allow_only_windows_credential IS NOT NULL)
  BEGIN
    IF(@allow_only_windows_credential = 1)
    BEGIN
       -- Allow only windows credentials. ( domain\user format)
       IF(CHARINDEX(N'\', @credential_identity) = 0)
       BEGIN
          RAISERROR(14720, -1, -1, '@credential_name', @credential_name)
          RETURN(1) -- Failure
       END
    END
  END

  RETURN(0) -- Success
END

GO
