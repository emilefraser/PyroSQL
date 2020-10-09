SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PersistedStream](
	[SessionID] [varchar](32) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Index] [int] NOT NULL,
	[Content] [image] NULL,
	[Name] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[MimeType] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Extension] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Encoding] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Error] [nvarchar](512) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RefCount] [int] NOT NULL,
	[ExpirationDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
