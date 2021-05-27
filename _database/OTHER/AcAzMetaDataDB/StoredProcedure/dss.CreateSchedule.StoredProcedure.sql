SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[CreateSchedule]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[CreateSchedule] AS' 
END
GO
ALTER PROCEDURE [dss].[CreateSchedule]
    @SyncGroupId UNIQUEIDENTIFIER,
    @Interval bigInt,
    @Type int
AS
BEGIN TRY
        INSERT INTO [dss].[ScheduleTask]
        (
            SyncGroupId,
            Interval,
            LastUpdate,
            ExpirationTime,
            State,
            Type
        )
        VALUES
        (
        @SyncGroupId,
            @Interval,
            GETUTCDATE(),
            DATEADD(SECOND, @Interval,GETUTCDATE()),
            0,
            @Type
        )

END TRY
BEGIN CATCH
         -- get error infromation and raise error
        --EXECUTE [dss].[RethrowError]
        RETURN
END CATCH
GO
