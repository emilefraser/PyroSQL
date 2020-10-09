SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TransactionHistoryArchiveHUB](
	[TransactionHistoryArchiveVID] [bigint] IDENTITY(1,1) NOT NULL,
	[TransactionID] [bigint] NOT NULL
) ON [PRIMARY]

GO
