SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[Language_ReserveWord]') AND type in (N'U'))
BEGIN
CREATE TABLE [construct].[Language_ReserveWord](
	[ReserveWordId] [int] IDENTITY(0,1) NOT NULL,
	[ReserveWord] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TechnologyId] [int] NULL,
	[IsCurrent] [bit] NOT NULL,
	[IsFuture] [bit] NOT NULL,
	[StartDT] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[EndDT] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ReserveWordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([StartDT], [EndDT])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [construct].[Language_ReserveWord_History] )
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DF__Language___IsCur__246854D6]') AND type = 'D')
BEGIN
ALTER TABLE [construct].[Language_ReserveWord] ADD  DEFAULT ((1)) FOR [IsCurrent]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DF__Language___IsFut__255C790F]') AND type = 'D')
BEGIN
ALTER TABLE [construct].[Language_ReserveWord] ADD  DEFAULT ((0)) FOR [IsFuture]
END
GO
