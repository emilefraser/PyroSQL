SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[DocumentBelongsToParentDocumentLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[DocumentBelongsToParentDocumentLINK](
	[DocumentBelongsToParentDocumentVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[DocumentVID] [bigint] NOT NULL,
	[ParentDocumentVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DocumentBelongsToParentDocumentVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[DocumentVID] ASC,
	[ParentDocumentVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[DocumentVID] ASC,
	[ParentDocumentVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[DocumentVID] ASC,
	[ParentDocumentVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__DocumentB__Docum__6987862A]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentBelongsToParentDocumentLINK]'))
ALTER TABLE [datavault].[DocumentBelongsToParentDocumentLINK]  WITH CHECK ADD FOREIGN KEY([DocumentVID])
REFERENCES [datavault].[DocumentHUB] ([DocumentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__DocumentB__Docum__72B1C908]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentBelongsToParentDocumentLINK]'))
ALTER TABLE [datavault].[DocumentBelongsToParentDocumentLINK]  WITH CHECK ADD FOREIGN KEY([DocumentVID])
REFERENCES [datavault].[DocumentHUB] ([DocumentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__DocumentB__Docum__75193467]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentBelongsToParentDocumentLINK]'))
ALTER TABLE [datavault].[DocumentBelongsToParentDocumentLINK]  WITH CHECK ADD FOREIGN KEY([DocumentVID])
REFERENCES [datavault].[DocumentHUB] ([DocumentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__DocumentB__Paren__6A7BAA63]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentBelongsToParentDocumentLINK]'))
ALTER TABLE [datavault].[DocumentBelongsToParentDocumentLINK]  WITH CHECK ADD FOREIGN KEY([ParentDocumentVID])
REFERENCES [datavault].[DocumentHUB] ([DocumentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__DocumentB__Paren__73A5ED41]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentBelongsToParentDocumentLINK]'))
ALTER TABLE [datavault].[DocumentBelongsToParentDocumentLINK]  WITH CHECK ADD FOREIGN KEY([ParentDocumentVID])
REFERENCES [datavault].[DocumentHUB] ([DocumentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__DocumentB__Paren__760D58A0]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentBelongsToParentDocumentLINK]'))
ALTER TABLE [datavault].[DocumentBelongsToParentDocumentLINK]  WITH CHECK ADD FOREIGN KEY([ParentDocumentVID])
REFERENCES [datavault].[DocumentHUB] ([DocumentVID])
GO
