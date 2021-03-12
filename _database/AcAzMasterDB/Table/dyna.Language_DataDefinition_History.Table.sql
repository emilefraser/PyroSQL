SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dyna].[Language_DataDefinition_History]') AND type in (N'U'))
BEGIN
CREATE TABLE [dyna].[Language_DataDefinition_History](
	[DefinitionId] [int] NOT NULL,
	[DefinitionCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DefinitionName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DefinitionType] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DefinitionClass] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DefinitionClassSub] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DefinitionTSQL] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dyna].[Language_DataDefinition_History]') AND name = N'ix_Language_DataDefinition_History')
CREATE CLUSTERED INDEX [ix_Language_DataDefinition_History] ON [dyna].[Language_DataDefinition_History]
(
	[EndDT] ASC,
	[StartDT] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
