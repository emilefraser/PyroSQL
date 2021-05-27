SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[config].[Generic_History]') AND type in (N'U'))
BEGIN
CREATE TABLE [config].[Generic_History](
	[ConfigID] [int] NOT NULL,
	[ConfigCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ConfigDescription] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigClassId] [int] NOT NULL,
	[ConfigClassName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigValue] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ConfigValueType] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[config].[Generic_History]') AND name = N'ix_Generic_History')
CREATE CLUSTERED INDEX [ix_Generic_History] ON [config].[Generic_History]
(
	[EndDT] ASC,
	[StartDT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
