SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[TransactionSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[TransactionSAT](
	[TransactionVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[ActualCost] [money] NOT NULL,
	[Quantity] [int] NOT NULL,
	[ReferenceOrderID] [int] NOT NULL,
	[ReferenceOrderLineID] [int] NOT NULL,
	[TransactionDate] [datetime] NOT NULL,
	[TransactionType] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TransactionVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__6B3AC472]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionSAT]'))
ALTER TABLE [datavault].[TransactionSAT]  WITH CHECK ADD FOREIGN KEY([TransactionVID])
REFERENCES [datavault].[TransactionHUB] ([TransactionVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__74650750]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionSAT]'))
ALTER TABLE [datavault].[TransactionSAT]  WITH CHECK ADD FOREIGN KEY([TransactionVID])
REFERENCES [datavault].[TransactionHUB] ([TransactionVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__76CC72AF]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionSAT]'))
ALTER TABLE [datavault].[TransactionSAT]  WITH CHECK ADD FOREIGN KEY([TransactionVID])
REFERENCES [datavault].[TransactionHUB] ([TransactionVID])
GO
