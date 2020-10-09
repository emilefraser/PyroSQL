SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_maintplan_update_log
    --Updates the log_details table
    @task_detail_id      UNIQUEIDENTIFIER,       --Required
    @Line1              NVARCHAR(256),       --Required
    @Line2              NVARCHAR(256)   = NULL,
    @Line3              NVARCHAR(256)   = NULL,
    @Line4              NVARCHAR(256)   = NULL,
    @Line5              NVARCHAR(256)   = NULL,
    @server_name      sysname,            --Required
    @succeeded         TINYINT,           --Required
    @start_time           DATETIME,          --Required
    @end_time          DATETIME,          --Required
    @error_number     int=NULL,
    @error_message       NVARCHAR(max)   = NULL,
    @command           NVARCHAR(max)   = NULL
AS
BEGIN

   --Prep strings
   SET NOCOUNT ON
   SELECT @Line1 = LTRIM(RTRIM(@Line1))
   SELECT @Line2 = LTRIM(RTRIM(@Line2))
   SELECT @Line3 = LTRIM(RTRIM(@Line3))
   SELECT @Line4 = LTRIM(RTRIM(@Line4))
   SELECT @Line5 = LTRIM(RTRIM(@Line5))

   INSERT INTO msdb.dbo.sysmaintplan_logdetail(
        task_detail_id, 
        line1,
        line2, 
        line3, 
        line4, 
        line5, 
        server_name, 
        start_time, 
        end_time, 
        error_number, 
        error_message, 
        command, 
        succeeded)
   VALUES(
        @task_detail_id,
        @Line1,
        @Line2,
        @Line3,
        @Line4,
        @Line5,
        @server_name,
        @start_time,
        @end_time,
        @error_number,
        @error_message,
        @command,
        @succeeded)

    RETURN (@@ERROR)
END

GO
