SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[PKFKLinkField](
	[PKFKLinkFieldID] [int] IDENTITY(1,1) NOT NULL,
	[PKFKLinkID] [int] NOT NULL,
	[PrimaryKeyFieldID] [int] NOT NULL,
	[ForeignKeyFieldID] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
