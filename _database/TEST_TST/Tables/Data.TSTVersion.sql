SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Data].[TSTVersion](
	[TSTSignature] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MajorVersion] [int] NOT NULL,
	[MinorVersion] [int] NOT NULL,
	[SetupDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
