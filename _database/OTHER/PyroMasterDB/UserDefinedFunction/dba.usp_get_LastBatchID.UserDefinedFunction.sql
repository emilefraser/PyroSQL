SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[usp_get_LastBatchID]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE   FUNCTION [dba].[usp_get_LastBatchID]()
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
' 
END
GO
