SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[IllustrationSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[IllustrationSAT](
	[IllustrationVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Diagram] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IllustrationVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Illustrat__Illus__08A10A27]') AND parent_object_id = OBJECT_ID(N'[datavault].[IllustrationSAT]'))
ALTER TABLE [datavault].[IllustrationSAT]  WITH CHECK ADD FOREIGN KEY([IllustrationVID])
REFERENCES [datavault].[IllustrationHUB] ([IllustrationVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Illustrat__Illus__0B087586]') AND parent_object_id = OBJECT_ID(N'[datavault].[IllustrationSAT]'))
ALTER TABLE [datavault].[IllustrationSAT]  WITH CHECK ADD FOREIGN KEY([IllustrationVID])
REFERENCES [datavault].[IllustrationHUB] ([IllustrationVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Illustrat__Illus__7F76C749]') AND parent_object_id = OBJECT_ID(N'[datavault].[IllustrationSAT]'))
ALTER TABLE [datavault].[IllustrationSAT]  WITH CHECK ADD FOREIGN KEY([IllustrationVID])
REFERENCES [datavault].[IllustrationHUB] ([IllustrationVID])
GO
