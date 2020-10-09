SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[PKFKLink](
	[PKFKLinkID] [int] IDENTITY(1,1) NOT NULL,
	[LinkName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ParentHubNameVariation] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentHubID] [int] NOT NULL,
	[ChildHubID] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
