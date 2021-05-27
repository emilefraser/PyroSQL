SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[EmailAddressIsUsedByPersonLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[EmailAddressIsUsedByPersonLINK](
	[EmailAddressIsUsedByPersonVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[EmailAddressVID] [bigint] NOT NULL,
	[PersonVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[EmailAddressIsUsedByPersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmailAddressVID] ASC,
	[PersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmailAddressVID] ASC,
	[PersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmailAddressVID] ASC,
	[PersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmailAddr__Email__6E4C3B47]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmailAddressIsUsedByPersonLINK]'))
ALTER TABLE [datavault].[EmailAddressIsUsedByPersonLINK]  WITH CHECK ADD FOREIGN KEY([EmailAddressVID])
REFERENCES [datavault].[EmailAddressHUB] ([EmailAddressVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmailAddr__Email__77767E25]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmailAddressIsUsedByPersonLINK]'))
ALTER TABLE [datavault].[EmailAddressIsUsedByPersonLINK]  WITH CHECK ADD FOREIGN KEY([EmailAddressVID])
REFERENCES [datavault].[EmailAddressHUB] ([EmailAddressVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmailAddr__Email__79DDE984]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmailAddressIsUsedByPersonLINK]'))
ALTER TABLE [datavault].[EmailAddressIsUsedByPersonLINK]  WITH CHECK ADD FOREIGN KEY([EmailAddressVID])
REFERENCES [datavault].[EmailAddressHUB] ([EmailAddressVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmailAddr__Perso__6F405F80]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmailAddressIsUsedByPersonLINK]'))
ALTER TABLE [datavault].[EmailAddressIsUsedByPersonLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmailAddr__Perso__786AA25E]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmailAddressIsUsedByPersonLINK]'))
ALTER TABLE [datavault].[EmailAddressIsUsedByPersonLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmailAddr__Perso__7AD20DBD]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmailAddressIsUsedByPersonLINK]'))
ALTER TABLE [datavault].[EmailAddressIsUsedByPersonLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
