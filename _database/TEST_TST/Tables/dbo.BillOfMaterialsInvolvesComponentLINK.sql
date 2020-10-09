SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BillOfMaterialsInvolvesComponentLINK](
	[BillOfMaterialsInvolvesComponentVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[BillOfMaterialsVID] [bigint] NOT NULL,
	[ComponentProductVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
