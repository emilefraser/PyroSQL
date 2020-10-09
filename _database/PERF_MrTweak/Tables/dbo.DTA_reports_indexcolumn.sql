SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DTA_reports_indexcolumn](
	[IndexID] [int] NOT NULL,
	[ColumnID] [int] NOT NULL,
	[ColumnOrder] [int] NULL,
	[PartitionColumnOrder] [int] NOT NULL,
	[IsKeyColumn] [bit] NOT NULL,
	[IsDescendingColumn] [bit] NOT NULL
) ON [PRIMARY]

GO
