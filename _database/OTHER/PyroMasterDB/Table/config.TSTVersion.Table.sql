SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[TSTVersion]') AND type in (N'U'))
BEGIN
CREATE TABLE [config].[TSTVersion](
	[TSTSignature] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MajorVersion] [int] NOT NULL,
	[MinorVersion] [int] NOT NULL,
	[SetupDate] [datetime] NOT NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[DF__TSTVersio__Setup__52A420D2]') AND type = 'D')
BEGIN
ALTER TABLE [config].[TSTVersion] ADD  DEFAULT (getdate()) FOR [SetupDate]
END
GO
