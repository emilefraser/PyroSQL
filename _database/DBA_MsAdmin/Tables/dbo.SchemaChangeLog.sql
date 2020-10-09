SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SchemaChangeLog](
	[SchemaChangeLogID] [int] IDENTITY(1,1) NOT NULL,
	[CreateDate] [datetime] NULL,
	[LoginName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ComputerName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DBName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SQLEvent] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Schema] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ObjectName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SQLCmd] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[XmlEvent] [xml] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
