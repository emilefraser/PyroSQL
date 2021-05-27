SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[TransactionAppliesToProductLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[TransactionAppliesToProductLINK](
	[TransactionAppliesToProductVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductVID] [bigint] NOT NULL,
	[TransactionVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TransactionAppliesToProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[TransactionVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[TransactionVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[TransactionVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Produ__6581EB1C]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionAppliesToProductLINK]'))
ALTER TABLE [datavault].[TransactionAppliesToProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Produ__6EAC2DFA]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionAppliesToProductLINK]'))
ALTER TABLE [datavault].[TransactionAppliesToProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Produ__71139959]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionAppliesToProductLINK]'))
ALTER TABLE [datavault].[TransactionAppliesToProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__66760F55]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionAppliesToProductLINK]'))
ALTER TABLE [datavault].[TransactionAppliesToProductLINK]  WITH CHECK ADD FOREIGN KEY([TransactionVID])
REFERENCES [datavault].[TransactionHUB] ([TransactionVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__6FA05233]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionAppliesToProductLINK]'))
ALTER TABLE [datavault].[TransactionAppliesToProductLINK]  WITH CHECK ADD FOREIGN KEY([TransactionVID])
REFERENCES [datavault].[TransactionHUB] ([TransactionVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Transacti__Trans__7207BD92]') AND parent_object_id = OBJECT_ID(N'[datavault].[TransactionAppliesToProductLINK]'))
ALTER TABLE [datavault].[TransactionAppliesToProductLINK]  WITH CHECK ADD FOREIGN KEY([TransactionVID])
REFERENCES [datavault].[TransactionHUB] ([TransactionVID])
GO
