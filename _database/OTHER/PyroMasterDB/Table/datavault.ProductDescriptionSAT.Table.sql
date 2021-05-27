SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductDescriptionSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductDescriptionSAT](
	[ProductDescriptionVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Description] [varchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductDescriptionVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductDe__Produ__0EB90AD9]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductDescriptionSAT]'))
ALTER TABLE [datavault].[ProductDescriptionSAT]  WITH CHECK ADD FOREIGN KEY([ProductDescriptionVID])
REFERENCES [datavault].[ProductDescriptionHUB] ([ProductDescriptionVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductDe__Produ__17E34DB7]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductDescriptionSAT]'))
ALTER TABLE [datavault].[ProductDescriptionSAT]  WITH CHECK ADD FOREIGN KEY([ProductDescriptionVID])
REFERENCES [datavault].[ProductDescriptionHUB] ([ProductDescriptionVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductDe__Produ__1A4AB916]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductDescriptionSAT]'))
ALTER TABLE [datavault].[ProductDescriptionSAT]  WITH CHECK ADD FOREIGN KEY([ProductDescriptionVID])
REFERENCES [datavault].[ProductDescriptionHUB] ([ProductDescriptionVID])
GO
