SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DataSets](
	[ID] [uniqueidentifier] NOT NULL,
	[ItemID] [uniqueidentifier] NOT NULL,
	[LinkID] [uniqueidentifier] NULL,
	[Name] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL
) ON [PRIMARY]

GO
