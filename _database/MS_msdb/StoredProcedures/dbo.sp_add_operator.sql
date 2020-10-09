SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_add_operator
  @name                      sysname,
  @enabled                   TINYINT       = 1,
  @email_address             NVARCHAR(100) = NULL,
  @pager_address             NVARCHAR(100) = NULL,
  @weekday_pager_start_time  INT           = 090000, -- HHMMSS using 24 hour clock
  @weekday_pager_end_time    INT           = 180000, -- As above
  @saturday_pager_start_time INT           = 090000, -- As above
  @saturday_pager_end_time   INT           = 180000, -- As above
  @sunday_pager_start_time   INT           = 090000, -- As above
  @sunday_pager_end_time     INT           = 180000, -- As above
  @pager_days                TINYINT       = 0,      -- 1 = Sunday .. 64 = Saturday
  @netsend_address           NVARCHAR(100) = NULL,   -- New for 7.0
  @category_name             sysname       = NULL    -- New for 7.0
AS
BEGIN
  DECLARE @return_code TINYINT
  DECLARE @category_id INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name            = LTRIM(RTRIM(@name))
  SELECT @email_address   = LTRIM(RTRIM(@email_address))
  SELECT @pager_address   = LTRIM(RTRIM(@pager_address))
  SELECT @netsend_address = LTRIM(RTRIM(@netsend_address))
  SELECT @category_name   = LTRIM(RTRIM(@category_name))

  -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported option
  IF (@netsend_address <> N'' AND SERVERPROPERTY('EngineEdition') = 8)
  BEGIN
    RAISERROR(41914, -1, 12, 'NetSend')
    RETURN(1) -- Failure
  END

  -- Turn [nullable] empty string parameters into NULLs
  IF (@email_address   = N'') SELECT @email_address   = NULL
  IF (@pager_address   = N'') SELECT @pager_address   = NULL
  IF (@netsend_address = N'') SELECT @netsend_address = NULL
  IF (@category_name   = N'') SELECT @category_name   = NULL

  -- Only a sysadmin can do this
  IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1))
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  IF (@category_name IS NULL)
  BEGIN
    SELECT @category_name = name
    FROM msdb.dbo.syscategories
    WHERE (category_id = 99)
  END

  -- Verify the operator
  EXECUTE @return_code = sp_verify_operator @name,
                                            @enabled,
                                            @pager_days,
                                            @weekday_pager_start_time,
                                            @weekday_pager_end_time,
                                            @saturday_pager_start_time,
                                            @saturday_pager_end_time,
                                            @sunday_pager_start_time,
                                            @sunday_pager_end_time,
                                            @category_name,
                                            @category_id OUTPUT
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  -- Finally, do the INSERT
  INSERT INTO msdb.dbo.sysoperators
         (name,
          enabled,
          email_address,
          last_email_date,
          last_email_time,
          pager_address,
          last_pager_date,
          last_pager_time,
          weekday_pager_start_time,
          weekday_pager_end_time,
          saturday_pager_start_time,
          saturday_pager_end_time,
          sunday_pager_start_time,
          sunday_pager_end_time,
          pager_days,
          netsend_address,
          last_netsend_date,
          last_netsend_time,
          category_id)
  VALUES (@name,
          @enabled,
          @email_address,
          0,
          0,
          @pager_address,
          0,
          0,
          @weekday_pager_start_time,
          @weekday_pager_end_time,
          @saturday_pager_start_time,
          @saturday_pager_end_time,
          @sunday_pager_start_time,
          @sunday_pager_end_time,
          @pager_days,
          @netsend_address,
          0,
          0,
          @category_id)

  RETURN(@@error) -- 0 means success
END

GO
