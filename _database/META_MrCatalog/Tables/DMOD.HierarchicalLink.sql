SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[HierarchicalLink](
	[HierarchicalLinkID] [int] IDENTITY(1,1) NOT NULL,
	[HubID] [int] NOT NULL,
	[HierarchicalLinkName] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PKFieldID] [int] NOT NULL,
	[ParentFieldID] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
