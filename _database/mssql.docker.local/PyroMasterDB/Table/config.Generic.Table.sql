SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[Generic]') AND type in (N'U'))
BEGIN
CREATE TABLE [config].[Generic](
	[ConfigID] [int] IDENTITY(0,1) NOT NULL,
	[ConfigCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ConfigDescription] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigClassId] [int] NOT NULL,
	[ConfigClassName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigValue] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigValueType] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[StartDT] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[EndDT] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_Generic_ConfigId] PRIMARY KEY CLUSTERED 
(
	[ConfigID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([StartDT], [EndDT])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [config].[Generic_History] )
)
END
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[config].[Generic]') AND name = N'uncix_Generic_ix01')
CREATE UNIQUE NONCLUSTERED INDEX [uncix_Generic_ix01] ON [config].[Generic]
(
	[ConfigClassName] ASC,
	[ConfigCode] ASC
)
INCLUDE([ConfigValue],[ConfigValueType]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[DF__Generic__ConfigC__532343BF]') AND type = 'D')
BEGIN
ALTER TABLE [config].[Generic] ADD  DEFAULT ((0)) FOR [ConfigClassId]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[DF__Generic__IsActiv__541767F8]') AND type = 'D')
BEGIN
ALTER TABLE [config].[Generic] ADD  DEFAULT ((1)) FOR [IsActive]
END
GO
