SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

create proc sp_enlist_tsx
   @Action int,            -- 0 - enlist; 1 - defect; 2 - update
   @ServerName  sysname,      -- tsx server name
   @Location  nvarchar(200),  -- tsx server location
   @TimeZoneAdjustment int,   -- tsx server time zone adjustment
   @LocalTime datetime,    -- tsx server local time
   @NTUserName nvarchar(100), -- name of the user performing the enlistment
   @PollInterval int,          -- polling interval
    @TSX_Version int = 0        -- VersionMajor: ((@TSX_Version / 0x1000000) & 0xff)
                                -- VersionMinor: ((@TSX_Version / 0x10000) & 0xff)
                                -- Build no:      (@TSX_Version & 0xFFFF)
as
begin
   SET NOCOUNT ON

   /* check permissions */
   IF (ISNULL(IS_MEMBER(N'TargetServersRole'), 0) = 0) AND (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 0)
   begin
   raiserror(15003,-1,-1, N'TargetServersRole')
   return 1
   end

   --9.0 and above servers set this version param
   if(@TSX_Version is null)
      set @TSX_Version = 0

   --Only check version during enlistment
   if(@Action = 0 AND ((@TSX_Version / 0x1000000) & 0xff) < 9)
   begin
      DECLARE @majorVer int, @minorVer int, @buildNo int
      SELECT @majorVer = ((@@microsoftversion / 0x1000000) & 0xff),
             @minorVer = ((@@microsoftversion / 0x10000) & 0xff),
             @buildNo = (@@microsoftversion & 0xfff)

      raiserror(14306, -1, -1, @majorVer, @minorVer, @buildNo )
      return 12
   end

   /* check input parameters */
   if @ServerName is null
   begin
   raiserror(14043, -1, -1, '@ServerName')
   return 2
   end

   select @ServerName = LTRIM(@ServerName)
   select @ServerName = RTRIM(@ServerName)
   if @ServerName = ''
   begin
   raiserror(21263, -1, -1, '@ServerName')
   return 3
   end

   select @ServerName = UPPER(@ServerName)

   if @Action <> 1 And @Action <> 2
   begin
   /* default action is to enlist */
   select @Action = 0
   end

  if @Action = 0 /* enlisting */
  begin
   /* check input parameters */
   if @NTUserName is null
   begin
      raiserror(14043, -1, -1, '@NTUserName')
      return 4
   end

   select @NTUserName = LTRIM(@NTUserName)
   select @NTUserName = RTRIM(@NTUserName)
   if @NTUserName = ''
   begin
     raiserror(21263, -1, -1, '@NTUserName')
     return 5
   end

   /* check if local server is already configured as TSX machine */
   declare @msx_server_name sysname
   select @msx_server_name = N''

   execute master.dbo.xp_instance_regread
      N'HKEY_LOCAL_MACHINE',
      N'Software\Microsoft\MSSQLServer\SQLServerAgent',
      N'MSXServerName',
      @msx_server_name OUTPUT

   select @msx_server_name = LTRIM(@msx_server_name)
   select @msx_server_name = RTRIM(@msx_server_name)
   if @msx_server_name <> N''
   begin
      raiserror(14360, -1, -1, @@SERVERNAME)
      return 6
   end

   /*
   * check that local server is not running a desktop SKU,
   * i.e. Win9x, Office, or MSDE
   */
   if( PLATFORM() & 0x100 = 0x100 )
   begin
      raiserror(14362, -1, -1)
      return 8
   end

   /* check if we have any MSXOperators defined */
   if not exists (SELECT * FROM msdb.dbo.sysoperators WHERE name = N'MSXOperator')
   begin
      raiserror(14363, -1, -1)
      return 9
   end

   /* all checks have passed, insert new row into systargetservers table */
   INSERT INTO msdb.dbo.systargetservers
   (
   server_name,
   location,
   time_zone_adjustment,
   enlist_date,
   last_poll_date,
   status,
   local_time_at_last_poll,
   enlisted_by_nt_user,
   poll_interval
   )
   VALUES
   (
   @ServerName,
   @Location,
   @TimeZoneAdjustment,
   GETDATE(),
   GETDATE(),
   1,
   @LocalTime,
   @NTUserName,
   @PollInterval
   )

   /* delete left behind rows from sysdownloadlist */
   DELETE FROM msdb.dbo.sysdownloadlist
   WHERE target_server = @ServerName
   end

   if @Action = 2 /* updating existing enlistment */
   begin
   /* check if we have any MSXOperators defined */
   if not exists (SELECT * FROM msdb.dbo.sysoperators WHERE name = N'MSXOperator')
   begin
      raiserror(14363, -1, -1)
      return 10
   end

   /* check if TSX machine is already enlisted */
   If not exists (SELECT * FROM msdb.dbo.systargetservers WHERE UPPER(server_name) = @ServerName)
   begin
      raiserror(14364, -1, -1)
      return 11
   end

   if @Location is null /* don't update the location if it is not supplied */
   begin
      UPDATE msdb.dbo.systargetservers SET
      time_zone_adjustment = @TimeZoneAdjustment,
      poll_interval = @PollInterval
      WHERE (UPPER(server_name) = @ServerName)
   end
   else
   begin
      UPDATE msdb.dbo.systargetservers SET
      location = @Location,
      time_zone_adjustment = @TimeZoneAdjustment,
      poll_interval = @PollInterval
      WHERE (UPPER(server_name) = @ServerName)
   end
   end

  if @Action = 1 /* defecting */
  begin
   if (exists (SELECT * FROM msdb.dbo.systargetservers WHERE UPPER(server_name) = @ServerName))
   begin
      execute msdb.dbo.sp_delete_targetserver
         @server_name = @ServerName,
         @post_defection = 0
   end
   else
   begin
      DELETE FROM msdb.dbo.sysdownloadlist
      WHERE (target_server = @ServerName)
   end
  end

  if @Action = 0 Or @Action = 2 /* enlisting or updating existing enlistment */
  begin
   /* select resultset to return to the caller */
   SELECT
   id,
   name,
   enabled,
   email_address,
   pager_address,
   netsend_address,
   weekday_pager_start_time,
   weekday_pager_end_time,
   saturday_pager_start_time,
   saturday_pager_end_time,
   sunday_pager_start_time,
   sunday_pager_end_time,
   pager_days
   FROM
   msdb.dbo.sysoperators WHERE (name = N'MSXOperator')
   end
end

GO
