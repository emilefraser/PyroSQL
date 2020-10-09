SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[Hub](
	[HubID] [int] IDENTITY(1,1) NOT NULL,
	[HubName] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[HubDataEntityID] [int] NULL,
	[DataDomainID] [int] NULL,
	[EnsembleStatus] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[IsReferenceHub] [bit] NULL
) ON [PRIMARY]

GO
