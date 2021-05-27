SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductModelSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductModelSAT](
	[ProductModelVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CatalogDescription] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Instructions] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductModelVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductMo__Produ__1DFB4E69]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductModelSAT]'))
ALTER TABLE [datavault].[ProductModelSAT]  WITH CHECK ADD FOREIGN KEY([ProductModelVID])
REFERENCES [datavault].[ProductModelHUB] ([ProductModelVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductMo__Produ__27259147]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductModelSAT]'))
ALTER TABLE [datavault].[ProductModelSAT]  WITH CHECK ADD FOREIGN KEY([ProductModelVID])
REFERENCES [datavault].[ProductModelHUB] ([ProductModelVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductMo__Produ__298CFCA6]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductModelSAT]'))
ALTER TABLE [datavault].[ProductModelSAT]  WITH CHECK ADD FOREIGN KEY([ProductModelVID])
REFERENCES [datavault].[ProductModelHUB] ([ProductModelVID])
GO
