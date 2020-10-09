SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BillOfMaterialsInvolvesProductAssemblyLINK](
	[BillOfMaterialsInvolvesProductAssemblyVI] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[BillOfMaterialsVID] [bigint] NOT NULL,
	[ProductAssemblyProductVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
