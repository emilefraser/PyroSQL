SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[DocumentSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[DocumentSAT](
	[DocumentVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[FolderFlag] [bit] NULL,
	[ChangeNumber] [int] NOT NULL,
	[DocumentFileName] [varchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DocumentRevision] [char](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FileExtension] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Status] [tinyint] NOT NULL,
	[Title] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Document] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DocumentSummary] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[DocumentVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__DocumentS__Docum__6D58170E]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentSAT]'))
ALTER TABLE [datavault].[DocumentSAT]  WITH CHECK ADD FOREIGN KEY([DocumentVID])
REFERENCES [datavault].[DocumentHUB] ([DocumentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__DocumentS__Docum__768259EC]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentSAT]'))
ALTER TABLE [datavault].[DocumentSAT]  WITH CHECK ADD FOREIGN KEY([DocumentVID])
REFERENCES [datavault].[DocumentHUB] ([DocumentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__DocumentS__Docum__78E9C54B]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentSAT]'))
ALTER TABLE [datavault].[DocumentSAT]  WITH CHECK ADD FOREIGN KEY([DocumentVID])
REFERENCES [datavault].[DocumentHUB] ([DocumentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__DocumentS__Statu__76AC771E]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentSAT]'))
ALTER TABLE [datavault].[DocumentSAT]  WITH CHECK ADD CHECK  (([Status]>=(1) AND [Status]<=(3)))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__DocumentS__Statu__7C062918]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentSAT]'))
ALTER TABLE [datavault].[DocumentSAT]  WITH CHECK ADD CHECK  (([Status]>=(1) AND [Status]<=(3)))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__DocumentS__Statu__7E6D9477]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentSAT]'))
ALTER TABLE [datavault].[DocumentSAT]  WITH CHECK ADD CHECK  (([Status]>=(1) AND [Status]<=(3)))
GO
