SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[PipelineOutput]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[PipelineOutput](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PipelineRunID] [uniqueidentifier] NULL,
	[DataFactoryName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PipelineName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PipelineTriggerID] [uniqueidentifier] NULL,
	[PipelineTriggerName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PipelineTriggerTime] [datetime2](7) NULL,
	[PipelineTriggerType] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OutputJSON] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
