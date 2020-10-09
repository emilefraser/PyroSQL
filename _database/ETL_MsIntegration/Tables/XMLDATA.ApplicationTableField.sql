SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [XMLDATA].[ApplicationTableField](
	[ApplicationTableFieldID] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationTableID] [int] NULL,
	[FieldCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FieldType] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FieldTitle] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
