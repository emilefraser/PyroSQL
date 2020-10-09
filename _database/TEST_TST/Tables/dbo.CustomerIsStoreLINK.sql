SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CustomerIsStoreLINK](
	[CustomerIsStoreVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[CustomerVID] [bigint] NOT NULL,
	[StoreVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
