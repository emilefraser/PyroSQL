SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[ReleaseConfig]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[ReleaseConfig](
	[ReleaseID] [int] IDENTITY(1,1) NOT NULL,
	[ReleaseType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AzureAccount] [uniqueidentifier] NOT NULL,
	[AzureContainer] [uniqueidentifier] NOT NULL,
	[ReleaseBlobPath]  AS ('AzureRoot\ContainerGUID\BlobGuid\date-{Release}\files'),
	[ReleaseDate]  AS (CONVERT([varchar](8),getdate(),(112))),
	[ReleaseName]  AS (CONVERT([varchar](8),getdate(),(112))+case when [ReleaseType]='Release' then '-Release' else '' end),
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_ReleaseConfig] PRIMARY KEY CLUSTERED 
(
	[ReleaseID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
