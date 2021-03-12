SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[GetMessageStatusBySyncGroupMemberId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[GetMessageStatusBySyncGroupMemberId] AS' 
END
GO

ALTER PROCEDURE [TaskHosting].[GetMessageStatusBySyncGroupMemberId]
    @SyncGroupMemberId UNIQUEIDENTIFIER,
    @StartTime DATETIME,
    @MaxExecTimes TINYINT,
    @TimeoutInSeconds INT,
    @HasMessage BIT OUTPUT,
    @HasRunningMessage BIT OUTPUT
AS
BEGIN
    IF @SyncGroupMemberId IS NULL
    BEGIN
        RAISERROR('@SyncGroupMemberId argument is wrong', 16, 1)
        RETURN
    END

    SET NOCOUNT ON

    SELECT
        @HasMessage = COUNT(*),
        @HasRunningMessage =
            COUNT
            (
                CASE WHEN
                -- Execute Times less than max, or execute times equal to max but it is still running, then return 1.
                    (ExecTimes < @MaxExecTimes) OR (ExecTimes = @MaxExecTimes AND UpdateTimeUTC >= DATEADD(SECOND, -@TimeoutInSeconds, GETUTCDATE()))
                THEN 1
                END
            )
    FROM TaskHosting.MessageQueue
    WHERE
        InsertTimeUTC >= @StartTime
        AND MessageData LIKE '%' + CONVERT(VARCHAR(50), @SyncGroupMemberId) + '%'

END

GO
