SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DTA_reports_partitionfunction](
	[PartitionFunctionID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseID] [int] NOT NULL,
	[PartitionFunctionName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PartitionFunctionDefinition] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
