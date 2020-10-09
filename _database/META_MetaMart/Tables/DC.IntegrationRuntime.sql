SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[IntegrationRuntime](
	[IntegrationRuntimeID] [int] IDENTITY(1,1) NOT NULL,
	[IntegrationRuntimeCode] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IntegrationRuntimeName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ServerLocationID] [int] NOT NULL
) ON [PRIMARY]

GO
