SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetUIHistoryRecords]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetUIHistoryRecords] AS' 
END
GO
ALTER PROCEDURE [dss].[GetUIHistoryRecords]
  @TimeRangeStart DATETIME = null,
  @TimeRangeEnd DATETIME = null,
  @RecordType int = null,
  @ServerId UNIQUEIDENTIFIER = null,
  @AgentId UNIQUEIDENTIFIER = null,
  @DatabaseId UNIQUEIDENTIFIER = null,
  @SyncGroupId UNIQUEIDENTIFIER = null,
  @NumberOfResults int = 100,
  @ContinuationTokenCompletionTime DATETIME = null,
  @ContinuationTokenEndTaskId UNIQUEIDENTIFIER = null
AS
BEGIN
  SET NOCOUNT ON
  SET ROWCOUNT @NumberOfResults

  IF
    @TimeRangeStart is NULL AND
    @TimeRangeEnd is NULL AND
    @AgentId is NULL AND
    @DatabaseId is NULL AND
    @SyncGroupId is NULL AND
    @RecordType is NULL
  BEGIN
    SELECT
        [id],
        [completionTime],
        [recordType],
        [serverid],
        [agentid],
        [databaseid],
        [syncgroupId],
        [detailEnumId],
        [detailStringParameters]
      FROM [dss].[UIHistory]
      WHERE [serverid] = @ServerId AND
       -- Skip previous returned log records, assume client query logs based on CompletionTime descending order
      (@ContinuationTokenCompletionTime IS NULL OR NOT ([completionTime] = @ContinuationTokenCompletionTime AND [id] <= @ContinuationTokenEndTaskId))
      ORDER BY CompletionTime DESC, id
    END
  ELSE
  BEGIN
    if @RecordType is NULL
      SELECT
        [id],
        [completionTime],
        [recordType],
        [serverid],
        [agentid],
        [databaseid],
        [syncgroupId],
        [detailEnumId],
        [detailStringParameters]
     FROM [dss].[UIHistory]
     WHERE
        [serverid] = @ServerId AND
        [completionTime] BETWEEN --BETWEEN is an inclusive operator
           ISNULL(@TimeRangeStart, CONVERT(datetime, '1/1/1753')) AND
           ISNULL(@TimeRangeEnd, getutcdate()) AND
        [agentid] = ISNULL(@AgentId, [dss].[UIHistory].[agentid]) AND
        [databaseid] = ISNULL(@DatabaseId, [dss].[UIHistory].[databaseid]) AND
        [syncgroupId] = ISNULL(@SyncGroupId, [dss].[UIHistory].[syncgroupId]) AND
        (@ContinuationTokenCompletionTime IS NULL OR NOT ([completionTime] = @ContinuationTokenCompletionTime AND [id] <= @ContinuationTokenEndTaskId))
        ORDER BY CompletionTime DESC, id
  ELSE
     SELECT
       [id],
       [completionTime],
       [recordType],
       [serverid],
       [agentid],
       [databaseid],
       [syncgroupId],
       [detailEnumId],
       [detailStringParameters]
     FROM [dss].[UIHistory]
     WHERE
       [serverid] = @ServerId AND
       [recordType] = @RecordType AND
       [completionTime] BETWEEN --BETWEEN is an inclusive operator
          ISNULL(@TimeRangeStart, CONVERT(datetime, '1/1/1753')) AND
          ISNULL(@TimeRangeEnd, getutcdate()) AND
       [agentid] = ISNULL(@AgentId, [dss].[UIHistory].[agentid]) AND
       [databaseid] = ISNULL(@DatabaseId, [dss].[UIHistory].[databaseid]) AND
       [syncgroupId] = ISNULL(@SyncGroupId, [dss].[UIHistory].[syncgroupId]) AND
        (@ContinuationTokenCompletionTime IS NULL OR NOT ([completionTime] = @ContinuationTokenCompletionTime AND [id] <= @ContinuationTokenEndTaskId))
       ORDER BY CompletionTime DESC, id
  END
END
GO
