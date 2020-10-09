SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [XMLDATA].[ApplicationTableFieldAttribute](
	[ApplicationTableFieldAttributeID] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationTableFieldID] [int] NOT NULL,
	[AttributeFieldKey] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AttributeFieldValue] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AttributeFieldDescription] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
