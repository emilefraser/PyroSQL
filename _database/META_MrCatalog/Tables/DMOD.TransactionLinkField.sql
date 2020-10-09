SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[TransactionLinkField](
	[TransactionLinkFieldID] [int] IDENTITY(1,1) NOT NULL,
	[TransactionLinkID] [int] NOT NULL,
	[FieldID] [int] NOT NULL
) ON [PRIMARY]

GO
