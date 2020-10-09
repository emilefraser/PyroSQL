SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[LinkDatabaseTechnologyTypeToDataLoadTechnologyType](
	[LinkTechnologyTypeToDataLoadID] [int] IDENTITY(1,1) NOT NULL,
	[DataLoadTechnologyTypeID] [int] NOT NULL,
	[DatabaseTechnologyTypeID] [int] NOT NULL
) ON [PRIMARY]

GO
