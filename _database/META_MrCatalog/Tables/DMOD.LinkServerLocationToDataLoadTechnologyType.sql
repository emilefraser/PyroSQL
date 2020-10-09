SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[LinkServerLocationToDataLoadTechnologyType](
	[LinkServerLocationToTechnologyTypeID] [int] IDENTITY(1,1) NOT NULL,
	[ServerLocationID] [int] NOT NULL,
	[DataLoadTechnologyTypeID] [int] NOT NULL
) ON [PRIMARY]

GO
