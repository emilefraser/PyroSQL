SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[HistoryTracking_Size](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[HistoryDT] [datetime2](7) NOT NULL,
	[ObjectID] [int] NOT NULL,
	[ObjectTypeID] [int] NOT NULL,
	[Size_MB] [decimal](18, 3) NULL
) ON [PRIMARY]

GO
