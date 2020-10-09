SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[LinkHubToManyToManyLink](
	[LinkHubToManyToManyLinkID] [int] IDENTITY(1,1) NOT NULL,
	[ManyToManyLinkID] [int] NOT NULL,
	[HubID] [int] NOT NULL,
	[HubSortOrder] [int] NOT NULL
) ON [PRIMARY]

GO
