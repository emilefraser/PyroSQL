SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[AddExecutionLogEntryByReportId]
    @InstanceName nvarchar(38),
    @ReportID uniqueidentifier,
    @UserSid varbinary(85) = NULL,
    @UserName nvarchar(260),
    @AuthType int,
    @RequestType tinyint,
    @Format nvarchar(26),
    @Parameters ntext,
    @TimeStart DateTime,
    @TimeEnd DateTime,
    @TimeDataRetrieval int,
    @TimeProcessing int,
    @TimeRendering int,
    @Source tinyint,
    @Status nvarchar(40),
    @ByteCount bigint,
    @RowCount bigint,
    @ExecutionId nvarchar(64) = null,
    @ReportAction tinyint,
    @AdditionalInfo xml = null
AS

-- Unless is is specifically 'False', it's true
IF EXISTS (SELECT * FROM ConfigurationInfo WHERE [Name] = 'EnableExecutionLogging' AND [Value] LIKE 'False')
BEGIN
    RETURN
END

INSERT INTO ExecutionLogStorage
    (InstanceName, ReportID, UserName, ExecutionId, RequestType, [Format], Parameters, ReportAction, TimeStart, TimeEnd, TimeDataRetrieval, TimeProcessing, TimeRendering, Source, Status, ByteCount, [RowCount], AdditionalInfo)
VALUES
    (@InstanceName, @ReportID, @UserName, @ExecutionId, @RequestType, @Format, @Parameters, @ReportAction, @TimeStart, @TimeEnd, @TimeDataRetrieval, @TimeProcessing, @TimeRendering, @Source, @Status, @ByteCount, @RowCount, @AdditionalInfo)
GO
