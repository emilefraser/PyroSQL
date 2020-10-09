SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [MASTER].[SortOrders](
	[SortOrderGroupName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SortOrderGroupCode] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FieldID] [int] NULL,
	[FieldName] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataEntityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemaName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DatabaseName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SortOrder] [int] NULL,
	[DataValue] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
