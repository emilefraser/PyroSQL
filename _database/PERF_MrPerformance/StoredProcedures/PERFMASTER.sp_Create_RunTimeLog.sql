SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE   PROCEDURE [PERFMASTER].[sp_Create_RunTimeLog]
AS

DROP TABLE IF EXISTS PERFTEST.RunTimeLog


CREATE TABLE [PERFMASTER].[RunTimeLog](
	[LogID]				int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Spid]				int NULL,
	[TestClass]			sysname NOT NULL,
	[TestName]			varchar(255) NULL,
	[TestIterationName] varchar(255) NULL,
	[TestRunNumber]		int NULL,
	[SourceObject]		varchar(255) NULL,
	[SourceRows]		int NULL,
	[TargetObject]		varchar(255) NULL,
	[TargetRows]		int NULL,
	[TestDefinition]	NVARCHAR(MAX),
	[StartDate]         DATETIME2(7) NOT NULL DEFAULT SYSUTCDATETIME(),
	[EndDate]           DATETIME2(7)
)

CREATE NONCLUSTERED INDEX ncix_RunTimeLog_TestName
ON PERFTEST.RunTimeLog(TestClass, TestName, TestIteration, TestRunNumber) 
INCLUDE (LogID, Spid, TestDefinition, [SourceObject], [SourceRows], [TargetObject], [TargetRows]
, StartDate, EndDate)

GO
