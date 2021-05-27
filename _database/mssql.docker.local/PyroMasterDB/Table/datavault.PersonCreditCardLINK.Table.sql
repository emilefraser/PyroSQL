SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[PersonCreditCardLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[PersonCreditCardLINK](
	[PersonCreditCardVID] [bigint] IDENTITY(1,1) NOT NULL,
	[PersonVID] [bigint] NOT NULL,
	[CreditCardVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PersonCreditCardVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PersonVID] ASC,
	[CreditCardVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PersonVID] ASC,
	[CreditCardVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PersonVID] ASC,
	[CreditCardVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonCre__Credi__025333F4]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonCreditCardLINK]'))
ALTER TABLE [datavault].[PersonCreditCardLINK]  WITH CHECK ADD FOREIGN KEY([CreditCardVID])
REFERENCES [datavault].[CreditCardHUB] ([CreditCardVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonCre__Credi__0B7D76D2]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonCreditCardLINK]'))
ALTER TABLE [datavault].[PersonCreditCardLINK]  WITH CHECK ADD FOREIGN KEY([CreditCardVID])
REFERENCES [datavault].[CreditCardHUB] ([CreditCardVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonCre__Credi__0DE4E231]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonCreditCardLINK]'))
ALTER TABLE [datavault].[PersonCreditCardLINK]  WITH CHECK ADD FOREIGN KEY([CreditCardVID])
REFERENCES [datavault].[CreditCardHUB] ([CreditCardVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonCre__Perso__0347582D]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonCreditCardLINK]'))
ALTER TABLE [datavault].[PersonCreditCardLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonCre__Perso__0C719B0B]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonCreditCardLINK]'))
ALTER TABLE [datavault].[PersonCreditCardLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonCre__Perso__0ED9066A]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonCreditCardLINK]'))
ALTER TABLE [datavault].[PersonCreditCardLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
