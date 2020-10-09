SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [procfwk].[PipelineAuthLink](
	[AuthId] [int] IDENTITY(1,1) NOT NULL,
	[PipelineId] [int] NOT NULL,
	[DataFactoryId] [int] NOT NULL,
	[CredentialId] [int] NOT NULL
) ON [PRIMARY]

GO
