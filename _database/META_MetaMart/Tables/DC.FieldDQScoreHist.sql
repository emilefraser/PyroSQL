SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[FieldDQScoreHist](
	[FieldID] [int] NOT NULL,
	[DQDate] [smalldatetime] NULL,
	[DQScore] [decimal](18, 2) NULL,
	[CreatedDT] [datetime2](7) NULL,
	[ModifiedDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
