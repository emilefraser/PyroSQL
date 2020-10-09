SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ServicePrincipals](
	[CredentialId] [int] IDENTITY(1,1) NOT NULL,
	[PrincipalName] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrincipalId] [uniqueidentifier] NULL,
	[PrincipalSecret] [varbinary](256) NULL,
	[PrincipalIdUrl] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrincipalSecretUrl] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
