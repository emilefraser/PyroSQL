SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductDocumentLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductDocumentLINK](
	[ProductDocumentVID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductVID] [bigint] NOT NULL,
	[DocumentVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductDocumentVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[DocumentVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[DocumentVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductVID] ASC,
	[DocumentVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductDo__Docum__0FAD2F12]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductDocumentLINK]'))
ALTER TABLE [datavault].[ProductDocumentLINK]  WITH CHECK ADD FOREIGN KEY([DocumentVID])
REFERENCES [datavault].[DocumentHUB] ([DocumentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductDo__Docum__18D771F0]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductDocumentLINK]'))
ALTER TABLE [datavault].[ProductDocumentLINK]  WITH CHECK ADD FOREIGN KEY([DocumentVID])
REFERENCES [datavault].[DocumentHUB] ([DocumentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductDo__Docum__1B3EDD4F]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductDocumentLINK]'))
ALTER TABLE [datavault].[ProductDocumentLINK]  WITH CHECK ADD FOREIGN KEY([DocumentVID])
REFERENCES [datavault].[DocumentHUB] ([DocumentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductDo__Produ__10A1534B]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductDocumentLINK]'))
ALTER TABLE [datavault].[ProductDocumentLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductDo__Produ__19CB9629]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductDocumentLINK]'))
ALTER TABLE [datavault].[ProductDocumentLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductDo__Produ__1C330188]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductDocumentLINK]'))
ALTER TABLE [datavault].[ProductDocumentLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
