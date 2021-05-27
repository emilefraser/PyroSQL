SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[Language_ReserveWord_History]') AND type in (N'U'))
BEGIN
CREATE TABLE [construct].[Language_ReserveWord_History](
	[ReserveWordId] [int] NOT NULL,
	[ReserveWord] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TechnologyId] [int] NULL,
	[IsCurrent] [bit] NOT NULL,
	[IsFuture] [bit] NOT NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[construct].[Language_ReserveWord_History]') AND name = N'ix_Language_ReserveWord_History')
CREATE CLUSTERED INDEX [ix_Language_ReserveWord_History] ON [construct].[Language_ReserveWord_History]
(
	[EndDT] ASC,
	[StartDT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
