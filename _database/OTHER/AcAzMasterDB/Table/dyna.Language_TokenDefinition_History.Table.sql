SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dyna].[Language_TokenDefinition_History]') AND type in (N'U'))
BEGIN
CREATE TABLE [dyna].[Language_TokenDefinition_History](
	[TokenDefinitionId] [int] NOT NULL,
	[TokenDefinitionCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TokenDefinitionName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TokenDefinitionType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TokenDefinition] [nvarchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TokenDefinitionTSQL] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dyna].[Language_TokenDefinition_History]') AND name = N'ix_Language_TokenDefinition_History')
CREATE CLUSTERED INDEX [ix_Language_TokenDefinition_History] ON [dyna].[Language_TokenDefinition_History]
(
	[EndDT] ASC,
	[StartDT] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
