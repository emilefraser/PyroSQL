SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [XMLDATA].[ApplicationViewField](
	[ApplicationViewFieldID] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationViewID] [int] NULL,
	[FieldCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FieldIndex] [smallint] NOT NULL,
	[FieldType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FieldTitle] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
