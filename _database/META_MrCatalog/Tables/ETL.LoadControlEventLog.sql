SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[LoadControlEventLog](
	[LoadControlID] [int] IDENTITY(1,1) NOT NULL,
	[EventDT] [datetime2](7) NOT NULL,
	[EventDescription] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ErrorMessage] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
