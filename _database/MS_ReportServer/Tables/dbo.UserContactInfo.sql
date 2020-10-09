SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[UserContactInfo](
	[UserID] [uniqueidentifier] NOT NULL,
	[DefaultEmailAddress] [nvarchar](256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
) ON [PRIMARY]

GO
