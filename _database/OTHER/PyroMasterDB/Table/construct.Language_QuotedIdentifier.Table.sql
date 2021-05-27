SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[Language_QuotedIdentifier]') AND type in (N'U'))
BEGIN
CREATE TABLE [construct].[Language_QuotedIdentifier](
	[LoadQuotedIdentifierID] [int] IDENTITY(1,1) NOT NULL,
	[QuotedIdentifierCode] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[QuotedIdentifier_Open] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[QuotedIdentifier_Close] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[QuotedIdentifier_Definition]  AS (concat([QuotedIdentifier_Open],'@{{OBJECTNAME}}',[QuotedIdentifier_Close])),
 CONSTRAINT [PK_LoadQuotedIdentifierID] PRIMARY KEY CLUSTERED 
(
	[LoadQuotedIdentifierID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
