SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Batch](
	[BatchID] [uniqueidentifier] NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[Action] [varchar](32) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Item] [nvarchar](425) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Parent] [nvarchar](425) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Param] [nvarchar](425) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[BoolParam] [bit] NULL,
	[Content] [image] NULL,
	[Properties] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
