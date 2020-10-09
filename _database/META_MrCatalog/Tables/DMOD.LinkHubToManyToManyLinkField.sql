SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[LinkHubToManyToManyLinkField](
	[LinkHubToManyToManyLinkFieldID] [int] IDENTITY(1,1) NOT NULL,
	[LinkHubToManyToManyLinkID] [int] NOT NULL,
	[HubPKFieldID] [int] NOT NULL,
	[ManyToManyTableFKFieldID] [int] NOT NULL
) ON [PRIMARY]

GO
