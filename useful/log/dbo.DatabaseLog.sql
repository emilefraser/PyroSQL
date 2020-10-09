SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DatabaseLog](
	[DatabaseLogID] [int] IDENTITY(1,1) NOT NULL,
	[PostTime] [datetime] NOT NULL,
	[DatabaseUser] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Event] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Schema] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Object] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TSQL] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[XmlEvent] [xml] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
