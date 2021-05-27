SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dyna].[Language_TemplateToken]') AND type in (N'U'))
BEGIN
CREATE TABLE [dyna].[Language_TemplateToken](
	[TemplateTokenId] [int] IDENTITY(0,1) NOT NULL,
	[TemplateTokenCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TemplateTokenName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TemplateTokenType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TemplateTokenDefinition] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TemplateTokenTsqlReplacement] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StartDT] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[EndDT] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TemplateTokenId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([StartDT], [EndDT])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [dyna].[Language_TemplateToken_History] )
)
END
GO
