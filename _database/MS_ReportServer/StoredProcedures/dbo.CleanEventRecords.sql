SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[CleanEventRecords]
@MaxAgeMinutes int
AS
-- Reset all notifications which have been add over n minutes ago
Update [Event] set [ProcessStart] = NULL, [ProcessHeartbeat] = NULL
where [EventID] in
   ( SELECT [EventID]
     FROM [Event]
     WHERE [ProcessHeartbeat] < DATEADD(minute, -(@MaxAgeMinutes), GETUTCDATE()) )
GO
