SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [ETL].[vw_Job]
AS
select [JobID]
      ,[JobID_SQL]
      ,[JobName_SQL]
      ,[Enable]
      ,[DateCreated_SQL]
      ,[DAteModified_SQL]
      ,[JobChecksum]
      ,[loadDT]
      ,[rn]
	 from [LastLoadedJobs](default)
GO
