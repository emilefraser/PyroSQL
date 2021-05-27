SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[ReleaseHistoryItem]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[ReleaseHistoryItem](
	[ReleaseHistoryItemID] [int] IDENTITY(1,1) NOT NULL,
	[ReleaseHistoryID] [int] NOT NULL,
	[ReleaseID] [int] NOT NULL,
	[ReleaseItemName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReleaseItemBlobStoragePath] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NULL
) ON [PRIMARY]
END
GO
