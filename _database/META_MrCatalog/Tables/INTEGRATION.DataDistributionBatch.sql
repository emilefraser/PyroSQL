SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [INTEGRATION].[DataDistributionBatch](
	[DataDistributionBatchID] [int] IDENTITY(1,1) NOT NULL,
	[DataEntityDDL] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[InsertPayload] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DeletePayload] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
