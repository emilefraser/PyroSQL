SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[CustomerSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[CustomerSAT](
	[CustomerVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[AccountNumber] [varchar](16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerS__Custo__679F3DB8]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerSAT]'))
ALTER TABLE [datavault].[CustomerSAT]  WITH CHECK ADD FOREIGN KEY([CustomerVID])
REFERENCES [datavault].[CustomerHUB] ([CustomerVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerS__Custo__70C98096]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerSAT]'))
ALTER TABLE [datavault].[CustomerSAT]  WITH CHECK ADD FOREIGN KEY([CustomerVID])
REFERENCES [datavault].[CustomerHUB] ([CustomerVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerS__Custo__7330EBF5]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerSAT]'))
ALTER TABLE [datavault].[CustomerSAT]  WITH CHECK ADD FOREIGN KEY([CustomerVID])
REFERENCES [datavault].[CustomerHUB] ([CustomerVID])
GO
