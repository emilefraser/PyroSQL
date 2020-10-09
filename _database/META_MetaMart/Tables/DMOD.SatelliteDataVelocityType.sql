SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[SatelliteDataVelocityType](
	[SatelliteDataVelocityTypeID] [smallint] IDENTITY(1,1) NOT NULL,
	[SatelliteDataVelocityTypeCode] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SatelliteDataVelocityTypeName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
