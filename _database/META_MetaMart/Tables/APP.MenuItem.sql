SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [APP].[MenuItem](
	[MenuItemID] [int] IDENTITY(1,1) NOT NULL,
	[MenuItemNavTo] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MenuItemParentID] [int] NULL,
	[IsHeaderItem] [bit] NULL,
	[SortOrder] [int] NULL,
	[HasChildren] [bit] NULL,
	[ModuleID] [int] NULL,
	[MenuItemName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
