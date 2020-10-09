SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REPREG].[ReportType](
	[ReportTypeID] [int] IDENTITY(1,1) NOT NULL,
	[ReportTypeDescription] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedBy] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[ModifiedBy] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ModifedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
