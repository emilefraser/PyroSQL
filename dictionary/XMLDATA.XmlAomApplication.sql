SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [XMLDATA].[XmlAomApplication](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[XMLData] [xml] NULL,
	[LoadedDateTime] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
