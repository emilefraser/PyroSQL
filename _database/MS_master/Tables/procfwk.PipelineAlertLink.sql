SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [procfwk].[PipelineAlertLink](
	[AlertId] [int] IDENTITY(1,1) NOT NULL,
	[PipelineId] [int] NOT NULL,
	[RecipientId] [int] NOT NULL,
	[OutcomesBitValue] [int] NOT NULL,
	[Enabled] [bit] NOT NULL
) ON [PRIMARY]

GO
