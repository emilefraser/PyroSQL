SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[TransactionHistoryIsAKindOfTransactionLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[TransactionHistoryIsAKindOfTransactionLINK](
	[TransactionHistoryIsAKindOfTransactionVI] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[TransactionHistoryVID] [bigint] NOT NULL,
	[TransactionVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TransactionHistoryIsAKindOfTransactionVI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[TransactionHistoryVID] ASC,
	[TransactionVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[TransactionHistoryVID] ASC,
	[TransactionVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[TransactionHistoryVID] ASC,
	[TransactionVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__69527C00]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionHistoryIsAKindOfTransactionLINK]'))
ALTER TABLE [datavault].[TransactionHistoryIsAKindOfTransactionLINK]  WITH CHECK ADD FOREIGN KEY([TransactionHistoryVID])
REFERENCES [datavault].[TransactionHistoryHUB] ([TransactionHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__6A46A039]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionHistoryIsAKindOfTransactionLINK]'))
ALTER TABLE [datavault].[TransactionHistoryIsAKindOfTransactionLINK]  WITH CHECK ADD FOREIGN KEY([TransactionVID])
REFERENCES [datavault].[TransactionHUB] ([TransactionVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__727CBEDE]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionHistoryIsAKindOfTransactionLINK]'))
ALTER TABLE [datavault].[TransactionHistoryIsAKindOfTransactionLINK]  WITH CHECK ADD FOREIGN KEY([TransactionHistoryVID])
REFERENCES [datavault].[TransactionHistoryHUB] ([TransactionHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__7370E317]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionHistoryIsAKindOfTransactionLINK]'))
ALTER TABLE [datavault].[TransactionHistoryIsAKindOfTransactionLINK]  WITH CHECK ADD FOREIGN KEY([TransactionVID])
REFERENCES [datavault].[TransactionHUB] ([TransactionVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__74E42A3D]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionHistoryIsAKindOfTransactionLINK]'))
ALTER TABLE [datavault].[TransactionHistoryIsAKindOfTransactionLINK]  WITH CHECK ADD FOREIGN KEY([TransactionHistoryVID])
REFERENCES [datavault].[TransactionHistoryHUB] ([TransactionHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__75D84E76]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionHistoryIsAKindOfTransactionLINK]'))
ALTER TABLE [datavault].[TransactionHistoryIsAKindOfTransactionLINK]  WITH CHECK ADD FOREIGN KEY([TransactionVID])
REFERENCES [datavault].[TransactionHUB] ([TransactionVID])
GO
