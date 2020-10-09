SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DYNREP].[DynamicReporting](
	[ReportID] [uniqueidentifier] NOT NULL,
	[DatabaseName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SchemaName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DataEntityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FieldID1] [int] NOT NULL,
	[FieldName1] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DataValue1] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FieldID2] [int] NULL,
	[FieldName2] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataValue2] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FieldID3] [int] NULL,
	[FieldName3] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataValue3] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
