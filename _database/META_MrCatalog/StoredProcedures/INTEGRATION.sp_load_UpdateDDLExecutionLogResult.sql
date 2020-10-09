SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =====================================================================
-- Author:		Francois Senekal
-- Create date: 24 Oct 2018
-- Description:	Update [EXECUTION].[DDLExecutionQueue] after DDL ran
-- =====================================================================

CREATE PROCEDURE [INTEGRATION].[sp_load_UpdateDDLExecutionLogResult]
@MaxID INT
AS
INSERT INTO FS.Logging_Steps( LogID
						,StepNo
						,[Platform]
						,[Action]
						,StartDT
						,FinishDT
						,Duration
						,IsError
						)
VALUES (@MaxID,8,'ADF','Copy to Azure has been completed',GETDATE(),GETDATE(),0,0)
UPDATE fs.Logging_Steps SET FinishDT = GETDATE(),
							Duration = ABS(DATEPART(SECOND,CONVERT(datetime2(7),GETDATE())) - (DATEPART(SECOND,StartDT)))
							WHERE LogID = @MaxID AND StepNo = 7
INSERT INTO FS.Logging_Steps( LogID
						,StepNo
						,[Platform]
						,[Action]
						,StartDT
						,FinishDT
						,Duration
						,IsError
						)
VALUES (@MaxID,9,'SQL Server','Updating DDL Execution Queue',GETDATE(),NULL,0,0)

UPDATE   deq
SET		 deq.[Result] = idel.[Result]
		,deq.[ErrorMessage] = idel.[ErrorMessage]
		,deq.[ErrorID] = idel.[ErrorID]
		,deq.[ExecutedDT] = idel.[CreatedDT]
FROM [INTEGRATION].[ingress_DDLExecutionLog] idel
	join [EXECUTION].[DDLExecutionQueue] deq
		ON deq.DDLExecutionQueueID = idel.DDLExecutionQueueID
INSERT INTO FS.Logging_Steps( LogID
						,StepNo
						,[Platform]
						,[Action]
						,StartDT
						,FinishDT
						,Duration
						,IsError
						)
VALUES (@MaxID,10,'SQL Server','Tables Updated',GETDATE(),GETDATE(),0,0)
UPDATE FS.Logging_Steps SET FinishDT = GETDATE(),
							Duration = ABS(DATEPART(SECOND,CONVERT(datetime2(7),GETDATE())) - (DATEPART(SECOND,StartDT)))
							WHERE LogID = @MaxID AND StepNo = 9

DECLARE @Error varchar(1000) = (SELECT TOP 1 IsError FROM FS.Logging_Steps WHERE LogID = 4 AND IsError = 1)
UPDATE FS.Logging_Header SET FinishDT = GETDATE(),
						  	 Duration = ABS((DATEPART(MINUTE,CONVERT(datetime2(7),GETDATE())) - (DATEPART(MINUTE,StartDT)))*60+(DATEPART(SECOND,CONVERT(datetime2(7),GETDATE())) - (DATEPART(SECOND,StartDT)))),
							 [Error Message] =  ISNULL(@Error,'Success')
							 WHERE LogID = @MaxID
TRUNCATE TABLE [INTEGRATION].[ingress_DDLExecutionLog]

GO
