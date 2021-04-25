SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductReviewSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductReviewSAT](
	[ProductReviewVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[EmailAddress] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Rating] [tinyint] NOT NULL,
	[ReviewDate] [datetime] NOT NULL,
	[ReviewerName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Comments] [varchar](3850) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductReviewVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductRe__Produ__24A84BF8]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductReviewSAT]'))
ALTER TABLE [datavault].[ProductReviewSAT]  WITH CHECK ADD FOREIGN KEY([ProductReviewVID])
REFERENCES [datavault].[ProductReviewHUB] ([ProductReviewVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductRe__Produ__2DD28ED6]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductReviewSAT]'))
ALTER TABLE [datavault].[ProductReviewSAT]  WITH CHECK ADD FOREIGN KEY([ProductReviewVID])
REFERENCES [datavault].[ProductReviewHUB] ([ProductReviewVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductRe__Produ__3039FA35]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductReviewSAT]'))
ALTER TABLE [datavault].[ProductReviewSAT]  WITH CHECK ADD FOREIGN KEY([ProductReviewVID])
REFERENCES [datavault].[ProductReviewHUB] ([ProductReviewVID])
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__ProductRe__Ratin__049B6F19]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductReviewSAT]'))
ALTER TABLE [datavault].[ProductReviewSAT]  WITH CHECK ADD CHECK  (([Rating]>=(1) AND [Rating]<=(5)))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__ProductRe__Ratin__0702DA78]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductReviewSAT]'))
ALTER TABLE [datavault].[ProductReviewSAT]  WITH CHECK ADD CHECK  (([Rating]>=(1) AND [Rating]<=(5)))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__ProductRe__Ratin__7F41BD1F]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductReviewSAT]'))
ALTER TABLE [datavault].[ProductReviewSAT]  WITH CHECK ADD CHECK  (([Rating]>=(1) AND [Rating]<=(5)))
GO
