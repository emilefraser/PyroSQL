SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[AzureResourceManager]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[AzureResourceManager](
	[$schema] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[contentVersion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
