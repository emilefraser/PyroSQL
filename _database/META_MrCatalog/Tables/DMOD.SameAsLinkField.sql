SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[SameAsLinkField](
	[SameAsLinkFieldID] [int] IDENTITY(1,1) NOT NULL,
	[SameAsLinkID] [int] NOT NULL,
	[MasterFieldID] [int] NOT NULL,
	[SlaveFieldID] [int] NOT NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
