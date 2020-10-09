SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[System](
	[SystemID] [int] IDENTITY(1,1) NOT NULL,
	[SystemName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SystemAbbreviation] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AccessInstructions] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UserID] [int] NULL,
	[IsBusinessApplication] [bit] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[DataDomainID] [int] NULL
) ON [PRIMARY]

GO
