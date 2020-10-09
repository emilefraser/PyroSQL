SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TransactionHistoryIsAKindOfTransactionLINK](
	[TransactionHistoryIsAKindOfTransactionVI] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[TransactionHistoryVID] [bigint] NOT NULL,
	[TransactionVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
