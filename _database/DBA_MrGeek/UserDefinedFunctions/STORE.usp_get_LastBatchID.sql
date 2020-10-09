SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   FUNCTION [STORE].[usp_get_LastBatchID]()
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @returnValue INT

	-- Add the T-SQL statements to compute the return value here
	SELECT @returnValue = MAX(BatchID) 
						   FROM STORE.StorageStats_Batch
							WHERE HasStorageStatsRun_Machine = 1
							AND HasStorageStatsRun_Database = 1
							AND HasStorageStatsRun_Object = 1
							AND HasStorageStatsRun_Index = 1
							AND HasStorageStatsRun_DatabaseFile= 1

	-- Return the result of the function
	RETURN @returnValue

END

GO
