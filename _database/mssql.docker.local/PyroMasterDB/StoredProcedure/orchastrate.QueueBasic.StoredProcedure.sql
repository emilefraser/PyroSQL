SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[orchastrate].[QueueBasic]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [orchastrate].[QueueBasic] AS' 
END
GO

/*
	EXEC orchastrate.QueueWithUpdAndReadPastLock
*/
ALTER   PROCEDURE [orchastrate].[QueueBasic]
AS
BEGIN

	SET NOCOUNT ON
	DECLARE @queueid INT 

	WHILE (SELECT COUNT(*) FROM DBO.QUEUE WITH (updlock, readpast)) >= 1

	BEGIN

	   BEGIN TRAN TRAN1 

	   SELECT TOP 1 @queueid = QUEUEID 
	   FROM orchastrate.QueueTable WITH (updlock, readpast) 

	   PRINT 'processing queueid # ' + CAST(@queueid AS VARCHAR) 

	   -- account for delay in processing time 
	   WAITFOR DELAY '00:00:05' 

	   DELETE FROM orchastrate.QueueTable
	   WHERE QUEUEID = @queueid
	   COMMIT
	END
END
GO
