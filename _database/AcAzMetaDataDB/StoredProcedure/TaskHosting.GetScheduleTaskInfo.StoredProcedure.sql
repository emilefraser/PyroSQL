SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[GetScheduleTaskInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[GetScheduleTaskInfo] AS' 
END
GO

-- create stored procedure [TaskHosting].[GetScheduleTaskInfo]

ALTER PROCEDURE [TaskHosting].[GetScheduleTaskInfo]
    @MessageId uniqueidentifier
AS
BEGIN -- stored procedure
    SET NOCOUNT ON

    SELECT * FROM [TaskHosting].[ScheduleTask]
    WHERE MessageId = @MessageId
END  -- stored procedure
GO
