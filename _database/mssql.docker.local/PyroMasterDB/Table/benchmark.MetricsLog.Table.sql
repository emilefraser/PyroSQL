SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[MetricsLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [benchmark].[MetricsLog](
	[LogID] [int] NOT NULL,
	[Spid] [int] NULL,
	[EstimatedCost] [float] NOT NULL,
	[Duration] [int] NULL,
	[CPU] [int] NULL,
	[Reads] [int] NULL,
	[Writes] [int] NULL,
	[EstimatedIOCost] [float] NULL,
	[EstimatedRows] [int] NULL,
	[ActualRows] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
