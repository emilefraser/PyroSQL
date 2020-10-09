SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[Satellite](
	[SatelliteID] [int] IDENTITY(1,1) NOT NULL,
	[HubID] [int] NOT NULL,
	[TransactionLinkID] [int] NULL,
	[SatelliteDataEnityID] [int] NULL,
	[SatelliteName] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SatelliteDataVelocityTypeID] [int] NOT NULL,
	[IsDetailTransactionLinkSat] [bit] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
