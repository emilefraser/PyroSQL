SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductReviewInvolvesProductLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductReviewInvolvesProductLINK](
	[ProductReviewInvolvesProductVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductVID] [bigint] NOT NULL,
	[ProductReviewVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductReviewInvolvesProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductReviewVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductReviewVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductReviewVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductRe__Produ__22C00386]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductReviewInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductReviewInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductReviewVID])
REFERENCES [datavault].[ProductReviewHUB] ([ProductReviewVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductRe__Produ__23B427BF]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductReviewInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductReviewInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductRe__Produ__2BEA4664]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductReviewInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductReviewInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductReviewVID])
REFERENCES [datavault].[ProductReviewHUB] ([ProductReviewVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductRe__Produ__2CDE6A9D]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductReviewInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductReviewInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductRe__Produ__2E51B1C3]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductReviewInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductReviewInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductReviewVID])
REFERENCES [datavault].[ProductReviewHUB] ([ProductReviewVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductRe__Produ__2F45D5FC]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductReviewInvolvesProductLINK]'))
ALTER TABLE [datavault].[ProductReviewInvolvesProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
