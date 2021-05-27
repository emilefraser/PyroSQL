SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[UpdateScheduleWithState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[UpdateScheduleWithState] AS' 
END
GO
ALTER PROCEDURE [dss].[UpdateScheduleWithState]
    @Id UNIQUEIDENTIFIER,
    @PopTicket UNIQUEIDENTIFIER,
    @state int
AS
BEGIN TRY
BEGIN TRANSACTION
    IF(@PopTicket = NULL )
    BEGIN
            RAISERROR('INVALID Pop Ticket', 15, 1)
    END
    IF @state=4
    BEGIN
        UPDATE [dss].[ScheduleTask]
        SET
        State = @state,
        PopReceipt = NULL,
        DequeueCount = 0,
        ExpirationTime = DATEADD(SECOND, Interval,GETUTCDATE())
        WHERE [Id] = @Id
        AND PopReceipt = @PopTicket
    END
    ELSE IF @state =5
    BEGIN
        UPDATE [dss].[ScheduleTask]
        SET
        state = @state,
        [DequeueCount] =
            CASE
                WHEN [DequeueCount] < 254 -- This is a tinyint, so make sure we don't overflow
                    THEN [DequeueCount] + 1
                ELSE
                    [DequeueCount]
                END,
        ExpirationTime = DATEADD(SECOND, Interval,GETUTCDATE())
        WHERE [id] = @Id
        AND PopReceipt = @PopTicket
    END
    IF @@TRANCOUNT > 0
        BEGIN
            COMMIT TRANSACTION
        END


END TRY
BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

         -- get error infromation and raise error
            EXECUTE [dss].[RethrowError]
        RETURN
END CATCH
GO
