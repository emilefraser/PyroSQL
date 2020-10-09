SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[LoadConfig](
	[LoadConfigID] [int] IDENTITY(1,1) NOT NULL,
	[LoadTypeID] [int] NOT NULL,
	[SourceDataEntityID] [int] NOT NULL,
	[TargetDataEntityID] [int] NULL,
	[IsSetForReloadOnNextRun] [bit] NOT NULL,
	[OffsetDays] [int] NULL,
	[CreatedDT_FieldID] [int] NULL,
	[UpdatedDT_FieldID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO
