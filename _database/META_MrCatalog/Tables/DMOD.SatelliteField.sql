SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[SatelliteField](
	[SatelliteFieldID] [int] IDENTITY(1,1) NOT NULL,
	[FieldID] [int] NOT NULL,
	[SatelliteID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
