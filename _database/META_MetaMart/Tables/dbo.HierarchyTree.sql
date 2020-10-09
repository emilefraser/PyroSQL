SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[HierarchyTree](
	[ID] [int] NULL,
	[ParentID] [int] NULL,
	[Level] [int] NULL,
	[Code] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Name] [varchar](13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
