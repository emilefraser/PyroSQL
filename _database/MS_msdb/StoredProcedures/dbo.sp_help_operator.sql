SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_help_operator
  @operator_name sysname = NULL,
  @operator_id   INT     = NULL
AS
BEGIN
  DECLARE @operator_id_as_char VARCHAR(10)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @operator_name = LTRIM(RTRIM(@operator_name))
  IF (@operator_name = '') SELECT @operator_name = NULL

  -- Check operator name
  IF (@operator_name IS NOT NULL)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (name = @operator_name)))
    BEGIN
      RAISERROR(14262, -1, -1, '@operator_name', @operator_name)
      RETURN(1) -- Failure
    END
  END

  -- Check operator id
  IF (@operator_id IS NOT NULL)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id)
      RAISERROR(14262, -1, -1, '@operator_id', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  SELECT so.id,
         so.name,
         so.enabled,
         so.email_address,
         so.last_email_date,
         so.last_email_time,
         so.pager_address,
         so.last_pager_date,
         so.last_pager_time,
         so.weekday_pager_start_time,
         so.weekday_pager_end_time,
         so.saturday_pager_start_time,
         so.saturday_pager_end_time,
         so.sunday_pager_start_time,
         so.sunday_pager_end_time,
         so.pager_days,
         so.netsend_address,
         so.last_netsend_date,
         so.last_netsend_time,
         category_name = sc.name
  FROM msdb.dbo.sysoperators                  so
       LEFT OUTER JOIN msdb.dbo.syscategories sc ON (so.category_id = sc.category_id)
  WHERE ((@operator_name IS NULL) OR (so.name = @operator_name))
    AND ((@operator_id IS NULL) OR (so.id = @operator_id))
  ORDER BY so.name

  RETURN(@@error) -- 0 means success
END

GO
