SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TransactionHistoryArchiveIsAKindOfTransactionLINK](
	[TransactionHistoryArchiveIsAKindOfTranse] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[TransactionHistoryArchiveVID] [bigint] NOT NULL,
	[TransactionVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
