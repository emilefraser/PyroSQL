SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [MASTER].[SortOrderValue](
	[SortOrderValueID] [int] IDENTITY(1,1) NOT NULL,
	[SortOrderGroupingID] [int] NOT NULL,
	[SortOrder] [int] NOT NULL,
	[DataValue] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
