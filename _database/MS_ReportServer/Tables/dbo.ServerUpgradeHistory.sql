SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ServerUpgradeHistory](
	[UpgradeID] [bigint] IDENTITY(1,1) NOT NULL,
	[ServerVersion] [nvarchar](25) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[User] [nvarchar](128) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DateTime] [datetime] NULL
) ON [PRIMARY]

GO
