SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[usp_LongRunningJobs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[usp_LongRunningJobs] AS' 
END
GO
ALTER PROC [dba].[usp_LongRunningJobs] AS SELECT 1
GO
