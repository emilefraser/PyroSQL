SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[WorkOrderIsForProductLINK](
	[WorkOrderIsForProductVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductVID] [bigint] NOT NULL,
	[WorkOrderVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
