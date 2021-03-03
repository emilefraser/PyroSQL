SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

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
