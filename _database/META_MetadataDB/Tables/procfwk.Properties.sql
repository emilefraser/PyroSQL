SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [procfwk].[Properties](
	[PropertyId] [int] IDENTITY(1,1) NOT NULL,
	[PropertyName] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PropertyValue] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ValidFrom] [datetime] NOT NULL,
	[ValidTo] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
