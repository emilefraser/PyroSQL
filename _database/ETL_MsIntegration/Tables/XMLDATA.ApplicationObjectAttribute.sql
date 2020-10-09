SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [XMLDATA].[ApplicationObjectAttribute](
	[ApplicationObjectAttributeID] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationObjectID] [int] NOT NULL,
	[AttributeKey] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AttributeValue] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AttributeDescription] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
