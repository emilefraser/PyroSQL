SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SecData](
	[SecDataID] [uniqueidentifier] NOT NULL,
	[PolicyID] [uniqueidentifier] NOT NULL,
	[AuthType] [int] NOT NULL,
	[XmlDescription] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[NtSecDescPrimary] [image] NOT NULL,
	[NtSecDescSecondary] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[NtSecDescState] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
