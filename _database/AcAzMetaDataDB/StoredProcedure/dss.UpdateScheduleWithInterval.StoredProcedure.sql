SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[UpdateScheduleWithInterval]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[UpdateScheduleWithInterval] AS' 
END
GO
ALTER PROCEDURE [dss].[UpdateScheduleWithInterval]
    @SyncGroupId UNIQUEIDENTIFIER,
    @Interval bigint
AS
BEGIN
    UPDATE [dss].[ScheduleTask]
    SET
        Interval = @Interval,
        [ExpirationTime] = DATEADD(SECOND, @Interval, GETUTCDATE()) -- Also update the due time for the task when the interval is updated.
    WHERE [SyncGroupId] = @SyncGroupId
END
GO
