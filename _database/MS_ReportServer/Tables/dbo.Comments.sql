SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Comments](
	[CommentID] [bigint] IDENTITY(1,1) NOT NULL,
	[ItemID] [uniqueidentifier] NOT NULL,
	[UserID] [uniqueidentifier] NOT NULL,
	[ThreadID] [bigint] NULL,
	[Text] [nvarchar](2048) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NULL,
	[AttachmentID] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
