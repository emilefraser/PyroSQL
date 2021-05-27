SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DeleteSchedule]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[DeleteSchedule] AS' 
END
GO
ALTER PROCEDURE [dss].[DeleteSchedule]
    @SyncGroupId UNIQUEIDENTIFIER = NULL
AS
BEGIN
BEGIN TRY
    DELETE
    FROM [dss].[ScheduleTask]
    WHERE [SyncGroupId] = @SyncGroupId

END TRY
BEGIN CATCH
         -- get error infromation and raise error
            EXECUTE [dss].[RethrowError]
        RETURN

END CATCH

END
GO
