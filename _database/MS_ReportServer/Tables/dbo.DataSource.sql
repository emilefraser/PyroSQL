SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DataSource](
	[DSID] [uniqueidentifier] NOT NULL,
	[ItemID] [uniqueidentifier] NULL,
	[SubscriptionID] [uniqueidentifier] NULL,
	[Name] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Extension] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Link] [uniqueidentifier] NULL,
	[CredentialRetrieval] [int] NULL,
	[Prompt] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ConnectionString] [image] NULL,
	[OriginalConnectionString] [image] NULL,
	[OriginalConnectStringExpressionBased] [bit] NULL,
	[UserName] [image] NULL,
	[Password] [image] NULL,
	[Flags] [int] NULL,
	[Version] [int] NOT NULL,
	[DSIDNum] [bigint] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
