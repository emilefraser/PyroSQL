SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[asset].[TestAssetLargeArchive]') AND type in (N'U'))
BEGIN
CREATE TABLE [asset].[TestAssetLargeArchive](
	[DocImageID] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsUploaded] [bit] NULL,
	[URL] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadedDate] [datetime2](7) NULL
) ON [PRIMARY]
END
GO
