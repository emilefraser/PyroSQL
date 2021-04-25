SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[monitor].[AlertContacts]') AND type in (N'U'))
BEGIN
CREATE TABLE [monitor].[AlertContacts](
	[AlertName] [nvarchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EmailList] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EmailList2] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CellList] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
