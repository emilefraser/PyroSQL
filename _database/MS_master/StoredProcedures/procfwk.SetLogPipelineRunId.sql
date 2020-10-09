SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [procfwk].[SetLogPipelineRunId]
	(
	@ExecutionId UNIQUEIDENTIFIER,
	@StageId INT,
	@PipelineId INT,
	@RunId UNIQUEIDENTIFIER = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE
		[procfwk].[CurrentExecution]
	SET
		[AdfPipelineRunId] = @RunId
	WHERE
		[LocalExecutionId] = @ExecutionId
		AND [StageId] = @StageId
		AND [PipelineId] = @PipelineId
END;

GO
