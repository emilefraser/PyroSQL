SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Keys](
	[MachineName] [nvarchar](256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[InstallationID] [uniqueidentifier] NOT NULL,
	[InstanceName] [nvarchar](32) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Client] [int] NOT NULL,
	[PublicKey] [image] NULL,
	[SymmetricKey] [image] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
