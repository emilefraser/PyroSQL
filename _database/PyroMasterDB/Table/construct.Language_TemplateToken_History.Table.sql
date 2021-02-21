SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[Language_TemplateToken_History]') AND type in (N'U'))
BEGIN
CREATE TABLE [construct].[Language_TemplateToken_History](
	[TokenTypeId] [int] NOT NULL,
	[TokenTypeCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TokenTypeDescription] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TokenClassName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TokenTypeDefinition] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TokenTypeRegex] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TokenBraceLeft] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TokenBraceRight] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TokenResolutionObjectName] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TokenResolutionObjectType] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TokenResolutionObjectParameter] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TokenReplacementRank] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[construct].[Language_TemplateToken_History]') AND name = N'ix_Language_TemplateToken_History')
CREATE CLUSTERED INDEX [ix_Language_TemplateToken_History] ON [construct].[Language_TemplateToken_History]
(
	[EndDT] ASC,
	[StartDT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
