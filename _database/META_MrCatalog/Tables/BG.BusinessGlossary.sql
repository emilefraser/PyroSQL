SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [BG].[BusinessGlossary](
	[BusinessGlossaryID] [int] IDENTITY(1,1) NOT NULL,
	[BusinessArea] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BusinessTerm] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Definition] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
