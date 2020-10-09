SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_verify_operator
  @name                      sysname,
  @enabled                   TINYINT,
  @pager_days                TINYINT,
  @weekday_pager_start_time  INT,
  @weekday_pager_end_time    INT,
  @saturday_pager_start_time INT,
  @saturday_pager_end_time   INT,
  @sunday_pager_start_time   INT,
  @sunday_pager_end_time     INT,
  @category_name             sysname,
  @category_id               INT OUTPUT
AS
BEGIN
  DECLARE @return_code     TINYINT
  DECLARE @res_valid_range NVARCHAR(100)

  SET NOCOUNT ON

  SELECT @res_valid_range = FORMATMESSAGE(14209)

  -- Remove any leading/trailing spaces from parameters
  SELECT @name          = LTRIM(RTRIM(@name))
  SELECT @category_name = LTRIM(RTRIM(@category_name))

  -- The name must be unique
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysoperators
              WHERE (name = @name)))
  BEGIN
    RAISERROR(14261, 16, 1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Enabled must be 0 or 1
  IF (@enabled NOT IN (0, 1))
  BEGIN
    RAISERROR(14266, 16, 1, '@enabled', '0, 1')
    RETURN(1) -- Failure
  END

  -- Check PagerDays
  IF (@pager_days < 0) OR (@pager_days > 127)
  BEGIN
    RAISERROR(14266, 16, 1, '@pager_days', @res_valid_range)
    RETURN(1) -- Failure
  END

  -- Check Start/End Times
  EXECUTE @return_code = sp_verify_job_time @weekday_pager_start_time, '@weekday_pager_start_time'
  IF (@return_code <> 0)
    RETURN(1)

  EXECUTE @return_code = sp_verify_job_time @weekday_pager_end_time, '@weekday_pager_end_time'
  IF (@return_code <> 0)
    RETURN(1)

  EXECUTE @return_code = sp_verify_job_time @saturday_pager_start_time, '@saturday_pager_start_time'
  IF (@return_code <> 0)
    RETURN(1)

  EXECUTE @return_code = sp_verify_job_time @saturday_pager_end_time, '@saturday_pager_end_time'
  IF (@return_code <> 0)
    RETURN(1)

  EXECUTE @return_code = sp_verify_job_time @sunday_pager_start_time, '@sunday_pager_start_time'
  IF (@return_code <> 0)
    RETURN(1)

  EXECUTE @return_code = sp_verify_job_time @sunday_pager_end_time, '@sunday_pager_end_time'
  IF (@return_code <> 0)
    RETURN(1)

  -- Check category name
  IF (@category_name = N'[DEFAULT]')
    SELECT @category_id = 99
  ELSE
  BEGIN
    SELECT @category_id = category_id
    FROM msdb.dbo.syscategories
    WHERE (category_class = 3) -- Operators
      AND (category_type = 3) -- None
      AND (name = @category_name)
  END
  IF (@category_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@category_name', @category_name)
    RETURN(1) -- Failure
  END

  RETURN(0)
END

GO
