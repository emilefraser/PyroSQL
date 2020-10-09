SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[LinkTransactionLinkToHub](
	[LinkTransactionLinkToHubID] [int] IDENTITY(1,1) NOT NULL,
	[TransactionLinkID] [int] NOT NULL,
	[HubID] [int] NOT NULL
) ON [PRIMARY]

GO
