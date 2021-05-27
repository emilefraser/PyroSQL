SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE   PROCEDURE [PERFMASTER].[sp_Create_MetricsLog]
AS

DROP TABLE IF EXISTS [PERFMASTER].[MetricsLog]


CREATE TABLE [PERFMASTER].[MetricsLog](
	[LogID]				INT NOT NULL PRIMARY KEY,
	[Spid]				int NULL,
	[EstimatedCost]		FLOAT NOT NULL,
	[Duration]			INT NULL,
	[CPU]				INT NULL,
	[Reads]				INT NULL,
	[Writes]			INT NULL,
	[EstimatedIOCost]	FLOAT NULL,
	[EstimatedRows]		INT NULL,
	[ActualRows]		INT NULL,
)

CREATE NONCLUSTERED INDEX ncix_MetricsLog_LogID
ON [PERFMASTER].[MetricsLog]([LogID]) 
INCLUDE ([EstimatedCost], [Duration], [CPU], [Reads], [Writes], [EstimatedIOCost], [EstimatedRows], [ActualRows])

GO
