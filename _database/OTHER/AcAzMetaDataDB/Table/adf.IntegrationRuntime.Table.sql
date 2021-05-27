SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[IntegrationRuntime]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[IntegrationRuntime](
	[IntegrationRuntimeId] [int] IDENTITY(0,1) NOT NULL,
	[IntegrationRuntimeCode] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IntegrationRuntimeName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AuthenticationKeyId] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
 CONSTRAINT [PK_IntegrationRuntimeID] PRIMARY KEY CLUSTERED 
(
	[IntegrationRuntimeId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
