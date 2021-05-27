SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[TransactionHistoryArchiveIsAKindOfTransactionLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[TransactionHistoryArchiveIsAKindOfTransactionLINK](
	[TransactionHistoryArchiveIsAKindOfTranse] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[TransactionHistoryArchiveVID] [bigint] NOT NULL,
	[TransactionVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TransactionHistoryArchiveIsAKindOfTranse] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[TransactionHistoryArchiveVID] ASC,
	[TransactionVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[TransactionHistoryArchiveVID] ASC,
	[TransactionVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[TransactionHistoryArchiveVID] ASC,
	[TransactionVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__676A338E]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionHistoryArchiveIsAKindOfTransactionLINK]'))
ALTER TABLE [datavault].[TransactionHistoryArchiveIsAKindOfTransactionLINK]  WITH CHECK ADD FOREIGN KEY([TransactionHistoryArchiveVID])
REFERENCES [datavault].[TransactionHistoryArchiveHUB] ([TransactionHistoryArchiveVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__685E57C7]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionHistoryArchiveIsAKindOfTransactionLINK]'))
ALTER TABLE [datavault].[TransactionHistoryArchiveIsAKindOfTransactionLINK]  WITH CHECK ADD FOREIGN KEY([TransactionVID])
REFERENCES [datavault].[TransactionHUB] ([TransactionVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__7094766C]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionHistoryArchiveIsAKindOfTransactionLINK]'))
ALTER TABLE [datavault].[TransactionHistoryArchiveIsAKindOfTransactionLINK]  WITH CHECK ADD FOREIGN KEY([TransactionHistoryArchiveVID])
REFERENCES [datavault].[TransactionHistoryArchiveHUB] ([TransactionHistoryArchiveVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__71889AA5]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionHistoryArchiveIsAKindOfTransactionLINK]'))
ALTER TABLE [datavault].[TransactionHistoryArchiveIsAKindOfTransactionLINK]  WITH CHECK ADD FOREIGN KEY([TransactionVID])
REFERENCES [datavault].[TransactionHUB] ([TransactionVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__72FBE1CB]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionHistoryArchiveIsAKindOfTransactionLINK]'))
ALTER TABLE [datavault].[TransactionHistoryArchiveIsAKindOfTransactionLINK]  WITH CHECK ADD FOREIGN KEY([TransactionHistoryArchiveVID])
REFERENCES [datavault].[TransactionHistoryArchiveHUB] ([TransactionHistoryArchiveVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__73F00604]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionHistoryArchiveIsAKindOfTransactionLINK]'))
ALTER TABLE [datavault].[TransactionHistoryArchiveIsAKindOfTransactionLINK]  WITH CHECK ADD FOREIGN KEY([TransactionVID])
REFERENCES [datavault].[TransactionHUB] ([TransactionVID])
GO
