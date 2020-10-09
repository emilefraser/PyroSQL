SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[LoadGroupControlHeader](
	[LoadGroupControlID] [int] IDENTITY(1,1) NOT NULL,
	[LoadDescription] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadStatus] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadScheduleID] [int] NULL,
	[ActiveStepID] [int] NULL
) ON [PRIMARY]

GO
