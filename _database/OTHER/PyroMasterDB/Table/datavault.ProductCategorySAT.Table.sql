SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductCategorySAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductCategorySAT](
	[ProductCategoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductCategoryVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductCa__Produ__0AE879F5]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductCategorySAT]'))
ALTER TABLE [datavault].[ProductCategorySAT]  WITH CHECK ADD FOREIGN KEY([ProductCategoryVID])
REFERENCES [datavault].[ProductCategoryHUB] ([ProductCategoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductCa__Produ__1412BCD3]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductCategorySAT]'))
ALTER TABLE [datavault].[ProductCategorySAT]  WITH CHECK ADD FOREIGN KEY([ProductCategoryVID])
REFERENCES [datavault].[ProductCategoryHUB] ([ProductCategoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductCa__Produ__167A2832]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductCategorySAT]'))
ALTER TABLE [datavault].[ProductCategorySAT]  WITH CHECK ADD FOREIGN KEY([ProductCategoryVID])
REFERENCES [datavault].[ProductCategoryHUB] ([ProductCategoryVID])
GO
