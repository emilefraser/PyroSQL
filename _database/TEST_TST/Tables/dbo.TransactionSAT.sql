SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TransactionSAT](
	[TransactionVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[ActualCost] [money] NOT NULL,
	[Quantity] [int] NOT NULL,
	[ReferenceOrderID] [int] NOT NULL,
	[ReferenceOrderLineID] [int] NOT NULL,
	[TransactionDate] [datetime] NOT NULL,
	[TransactionType] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
