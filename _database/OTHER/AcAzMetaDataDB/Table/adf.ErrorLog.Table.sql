SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[ErrorLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[ErrorLog](
	[ErrorLogId] [int] IDENTITY(1,1) NOT NULL,
	[LocalExecutionId] [uniqueidentifier] NOT NULL,
	[AdfPipelineRunId] [uniqueidentifier] NOT NULL,
	[ActivityRunId] [uniqueidentifier] NOT NULL,
	[ActivityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ActivityType] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ErrorCode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ErrorType] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ErrorMessage] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED 
(
	[ErrorLogId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
