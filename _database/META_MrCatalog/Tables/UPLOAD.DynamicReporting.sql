SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [UPLOAD].[DynamicReporting](
	[ReportID] [uniqueidentifier] NOT NULL,
	[FieldID1] [int] NOT NULL,
	[DataValue1] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FieldID2] [int] NULL,
	[DataValue2] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FieldID3] [int] NULL,
	[DataValue3] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
