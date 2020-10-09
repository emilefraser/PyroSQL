SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[ETLStepDataCatalogRelation_Relation](
	[ETLStepDataCatalogRelationID] [int] IDENTITY(1,1) NOT NULL,
	[ETLStepID] [int] NOT NULL,
	[DataCatalogRelationID] [int] NOT NULL
) ON [PRIMARY]

GO
