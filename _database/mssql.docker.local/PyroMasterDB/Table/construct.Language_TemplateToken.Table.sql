SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[Language_TemplateToken]') AND type in (N'U'))
BEGIN
CREATE TABLE [construct].[Language_TemplateToken](
	[TokenTypeId] [int] IDENTITY(0,1) NOT NULL,
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
	[StartDT] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[EndDT] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TokenTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([StartDT], [EndDT])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [construct].[Language_TemplateToken_History] )
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DF__Language___IsAct__2E90DD8E]') AND type = 'D')
BEGIN
ALTER TABLE [construct].[Language_TemplateToken] ADD  DEFAULT ((1)) FOR [IsActive]
END
GO
