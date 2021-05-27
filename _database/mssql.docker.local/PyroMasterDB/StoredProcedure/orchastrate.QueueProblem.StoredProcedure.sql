SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[orchastrate].[QueueProblem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [orchastrate].[QueueProblem] AS' 
END
GO

/*
	EXEC orchastrate.QueueProblem
*/
ALTER   PROCEDURE [orchastrate].[QueueProblem]
AS
DECLARE @queueid INT

BEGIN TRAN TRAN1

SELECT TOP 1 @queueid = QUEUEID
FROM orchastrate.QueueTable

PRINT 'processing queueid # ' + CAST(@queueid AS VARCHAR)

-- account for delay in processing time
WAITFOR DELAY '00:00:10'

DELETE FROM Dorchastrate.QueueTable
WHERE QUEUEID = @queueid

COMMIT
GO
