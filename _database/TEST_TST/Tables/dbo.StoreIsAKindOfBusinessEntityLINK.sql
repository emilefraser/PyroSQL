SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[StoreIsAKindOfBusinessEntityLINK](
	[StoreIsAKindOfBusinessEntityVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[BusinessEntityVID] [bigint] NOT NULL,
	[StoreVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
