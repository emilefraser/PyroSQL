SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ConfigurationInfo](
	[ConfigInfoID] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Value] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
