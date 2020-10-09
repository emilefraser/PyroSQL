SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[DataEntityType](
	[DataEntityTypeID] [int] IDENTITY(1,1) NOT NULL,
	[DataEntityTypeName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DataEntityTypeCode] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DatabasePurposeID] [int] NULL,
	[IsAllowedInStageArea] [bit] NULL,
	[IsAllowedInRawVault] [bit] NOT NULL,
	[IsAllowedInBizVault] [bit] NOT NULL,
	[IsAllowedInInfoMart] [bit] NOT NULL,
	[IsAllowedInErrorMart] [bit] NOT NULL,
	[IsAllowedInMetricsMart] [bit] NOT NULL,
	[DataEntityNamingPrefix] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataEntityNamingSuffix] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
