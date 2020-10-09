SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[ETLRegister](
	[ETL_ID] [int] IDENTITY(1,1) NOT NULL,
	[ETLDescription] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CurrentStatus] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastRunDate] [datetime] NULL,
	[LastRunStatus] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
