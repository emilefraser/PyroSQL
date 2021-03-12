SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[CreateUIHistoryRecord]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[CreateUIHistoryRecord] AS' 
END
GO
-- Create the Insertion SP
-- Make sure this file is in ANSI format
ALTER PROCEDURE [dss].[CreateUIHistoryRecord]
    @Id	            UNIQUEIDENTIFIER,
    @CompletionTime DATETIME,
    @TaskType       INT,
    @RecordType     INT,
    @ServerId		UNIQUEIDENTIFIER,
    @AgentId		UNIQUEIDENTIFIER,
    @DatabaseId		UNIQUEIDENTIFIER,
    @SyncGroupId    UNIQUEIDENTIFIER,
    @DisplayEnumId  nvarchar(MAX),
    @DisplayParameters	nvarchar(MAX) = null,
    @IsWritable		bit = null
AS
BEGIN
    MERGE [dss].[UIHistory] as target
    USING (SELECT @Id, @CompletionTime, @TaskType, @RecordType, @ServerId, @AgentId, @DatabaseId, @SyncGroupId, @DisplayEnumId, @DisplayParameters, @IsWritable)
        AS source([Id], [CompletionTime],[TaskType], [RecordType], [ServerId], [AgentId], [DatabaseId], [SyncGroupId], [DetailEnumId], [DetailStringParameters], [IsWritable])
    ON source.Id = target.id
    WHEN MATCHED AND (target.[isWritable] = 1) THEN
        UPDATE SET
            [id] = source.[Id],
            [completionTime] = source.[CompletionTime],
            [taskType] = source.[TaskType],
            [recordType] = source.[RecordType],
            [serverid] = source.[ServerId],
            [agentid] = source.[AgentId],
            [databaseid] = source.[DatabaseId],
            [syncgroupId] = source.[SyncGroupId],
            [detailEnumId] = source.[DetailEnumId],
            [detailStringParameters] = source.[DetailStringParameters],
            [isWritable] = source.[IsWritable]
    WHEN NOT MATCHED THEN
        INSERT
        (
            [id],
            [completionTime],
            [taskType],
            [recordType],
            [serverid],
            [agentid],
            [databaseid],
            [syncgroupId],
            [detailEnumId],
            [detailStringParameters],
            [isWritable]
        )
        VALUES
        (
            source.[Id],
            source.[CompletionTime],
            source.[TaskType],
            source.[RecordType],
            source.[ServerId],
            source.[AgentId],
            source.[DatabaseId],
            source.[SyncGroupId],
            source.[DetailEnumId],
            source.[DetailStringParameters],
            source.[IsWritable]
        );
END
GO
