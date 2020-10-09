SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AlertContacts](
	[AlertName] [nvarchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EmailList] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EmailList2] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CellList] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
