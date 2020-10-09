SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [LOG].[FlowExecutionLog](
	[FlowExecutionLogID] [int] IDENTITY(1,1) NOT NULL,
	[FlowName] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MasterEntity] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TransactionData] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TransactionPerson] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsError] [bit] NULL,
	[ErrorDescription] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LogDT] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
