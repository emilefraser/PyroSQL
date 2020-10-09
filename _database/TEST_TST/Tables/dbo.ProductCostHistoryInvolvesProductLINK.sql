SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductCostHistoryInvolvesProductLINK](
	[ProductCostHistoryInvolvesProductVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductCostHistoryVID] [bigint] NOT NULL,
	[ProductVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
