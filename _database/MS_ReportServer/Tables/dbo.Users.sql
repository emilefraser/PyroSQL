SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Users](
	[UserID] [uniqueidentifier] NOT NULL,
	[Sid] [varbinary](85) NULL,
	[UserType] [int] NOT NULL,
	[AuthType] [int] NOT NULL,
	[UserName] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ServiceToken] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Setting] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ModifiedDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
