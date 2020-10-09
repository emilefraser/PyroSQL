SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[TransactionLink](
	[TransactionLinkID] [int] IDENTITY(1,1) NOT NULL,
	[SourceDataEntityID] [int] NOT NULL,
	[TransactionLinkName] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DataEntityHeaderPKFieldID] [int] NULL,
	[DataEntityDetailFKFieldID] [int] NULL
) ON [PRIMARY]

GO
