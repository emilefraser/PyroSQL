SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_verify_job_time
  @time           INT,
  @time_name      VARCHAR(60) = 'time',
  @error_severity INT = -1
AS
BEGIN
  DECLARE @hour      INT
  DECLARE @minute    INT
  DECLARE @second    INT
  DECLARE @part_name NVARCHAR(50)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @time_name = LTRIM(RTRIM(@time_name))

  IF ((@time < 0) OR (@time > 235959))
  BEGIN
    RAISERROR(14266, @error_severity, -1, @time_name, '000000..235959')
    RETURN(1) -- Failure
  END

  SELECT @hour   = (@time / 10000)
  SELECT @minute = (@time % 10000) / 100
  SELECT @second = (@time % 100)

  -- Check hour range
  IF (@hour > 23)
  BEGIN
    SELECT @part_name = FORMATMESSAGE(14218)
    RAISERROR(14287, @error_severity, -1, @time_name, @part_name)
    RETURN(1) -- Failure
  END

  -- Check minute range
  IF (@minute > 59)
  BEGIN
    SELECT @part_name = FORMATMESSAGE(14219)
    RAISERROR(14287, @error_severity, -1, @time_name, @part_name)
    RETURN(1) -- Failure
  END

  -- Check second range
  IF (@second > 59)
  BEGIN
    SELECT @part_name = FORMATMESSAGE(14220)
    RAISERROR(14287, @error_severity, -1, @time_name, @part_name)
    RETURN(1) -- Failure
  END

  RETURN(0) -- Success
END

GO
