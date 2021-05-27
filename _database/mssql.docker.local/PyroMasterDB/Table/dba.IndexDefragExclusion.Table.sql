SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[IndexDefragExclusion]') AND type in (N'U'))
BEGIN
CREATE TABLE [dba].[IndexDefragExclusion](
	[databaseID] [int] NOT NULL,
	[databaseName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[objectID] [int] NOT NULL,
	[objectName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[indexID] [int] NOT NULL,
	[indexName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[exclusionMask] [int] NOT NULL,
 CONSTRAINT [PK_indexDefragExclusion_v40] PRIMARY KEY CLUSTERED 
(
	[databaseID] ASC,
	[objectID] ASC,
	[indexID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
