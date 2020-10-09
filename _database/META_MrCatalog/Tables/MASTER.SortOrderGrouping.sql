SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [MASTER].[SortOrderGrouping](
	[SortOrderGroupingID] [int] IDENTITY(1,1) NOT NULL,
	[SortOrderGroupName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SortOrderGroupCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FieldID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[DataDomainID] [int] NULL
) ON [PRIMARY]

GO
