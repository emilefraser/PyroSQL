SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DTA_reports_partitionscheme](
	[PartitionSchemeID] [int] IDENTITY(1,1) NOT NULL,
	[PartitionFunctionID] [int] NOT NULL,
	[PartitionSchemeName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PartitionSchemeDefinition] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
