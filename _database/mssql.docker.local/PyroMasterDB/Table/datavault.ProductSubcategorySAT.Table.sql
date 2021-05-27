SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductSubcategorySAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductSubcategorySAT](
	[ProductSubcategoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductSubcategoryVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductSu__Produ__296D0115]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductSubcategorySAT]'))
ALTER TABLE [datavault].[ProductSubcategorySAT]  WITH CHECK ADD FOREIGN KEY([ProductSubcategoryVID])
REFERENCES [datavault].[ProductSubcategoryHUB] ([ProductSubcategoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductSu__Produ__329743F3]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductSubcategorySAT]'))
ALTER TABLE [datavault].[ProductSubcategorySAT]  WITH CHECK ADD FOREIGN KEY([ProductSubcategoryVID])
REFERENCES [datavault].[ProductSubcategoryHUB] ([ProductSubcategoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductSu__Produ__34FEAF52]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductSubcategorySAT]'))
ALTER TABLE [datavault].[ProductSubcategorySAT]  WITH CHECK ADD FOREIGN KEY([ProductSubcategoryVID])
REFERENCES [datavault].[ProductSubcategoryHUB] ([ProductSubcategoryVID])
GO
