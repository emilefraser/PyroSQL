SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_verify_job_date
  @date           INT,
  @date_name      VARCHAR(60) = 'date',
  @error_severity INT         = -1
AS
BEGIN
  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @date_name = LTRIM(RTRIM(@date_name))

  IF ((ISDATE(CONVERT(VARCHAR, @date)) = 0) OR (@date < 19900101) OR (@date > 99991231))
  BEGIN
    RAISERROR(14266, @error_severity, -1, @date_name, '19900101..99991231')
    RETURN(1) -- Failure
  END

  RETURN(0) -- Success
END

GO
