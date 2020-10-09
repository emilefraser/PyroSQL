SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [procfwk].[AlertOutcomes](
	[OutcomeBitPosition] [int] IDENTITY(0,1) NOT NULL,
	[PipelineOutcomeStatus] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BitValue]  AS (power((2),[OutcomeBitPosition]))
) ON [PRIMARY]

GO
