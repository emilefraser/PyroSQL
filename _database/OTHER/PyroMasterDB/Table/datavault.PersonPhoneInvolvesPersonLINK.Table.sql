SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[PersonPhoneInvolvesPersonLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[PersonPhoneInvolvesPersonLINK](
	[PersonPhoneInvolvesPersonVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[PersonPhoneVID] [bigint] NOT NULL,
	[PersonVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PersonPhoneInvolvesPersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PersonPhoneVID] ASC,
	[PersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PersonPhoneVID] ASC,
	[PersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PersonPhoneVID] ASC,
	[PersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonPho__Perso__0623C4D8]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonPhoneInvolvesPersonLINK]'))
ALTER TABLE [datavault].[PersonPhoneInvolvesPersonLINK]  WITH CHECK ADD FOREIGN KEY([PersonPhoneVID])
REFERENCES [datavault].[PersonPhoneHUB] ([PersonPhoneVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonPho__Perso__0717E911]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonPhoneInvolvesPersonLINK]'))
ALTER TABLE [datavault].[PersonPhoneInvolvesPersonLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonPho__Perso__0F4E07B6]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonPhoneInvolvesPersonLINK]'))
ALTER TABLE [datavault].[PersonPhoneInvolvesPersonLINK]  WITH CHECK ADD FOREIGN KEY([PersonPhoneVID])
REFERENCES [datavault].[PersonPhoneHUB] ([PersonPhoneVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonPho__Perso__10422BEF]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonPhoneInvolvesPersonLINK]'))
ALTER TABLE [datavault].[PersonPhoneInvolvesPersonLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonPho__Perso__11B57315]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonPhoneInvolvesPersonLINK]'))
ALTER TABLE [datavault].[PersonPhoneInvolvesPersonLINK]  WITH CHECK ADD FOREIGN KEY([PersonPhoneVID])
REFERENCES [datavault].[PersonPhoneHUB] ([PersonPhoneVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonPho__Perso__12A9974E]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonPhoneInvolvesPersonLINK]'))
ALTER TABLE [datavault].[PersonPhoneInvolvesPersonLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
