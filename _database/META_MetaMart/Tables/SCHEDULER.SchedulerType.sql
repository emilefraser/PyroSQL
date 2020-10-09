SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [SCHEDULER].[SchedulerType](
	[SchedulerTypeID] [int] IDENTITY(1,1) NOT NULL,
	[SchedulerTypeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchedulerTypeDescription] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchedulerTypeName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
