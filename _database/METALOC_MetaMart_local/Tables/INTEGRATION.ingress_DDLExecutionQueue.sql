SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [INTEGRATION].[ingress_DDLExecutionQueue](
	[DDLExecutionQueueID] [int] IDENTITY(1,1) NOT NULL,
	[DDLQueryText] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DDLQueryDescription] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TargetDatabaseInstanceID] [int] NOT NULL,
	[Result] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[ErrorMessage] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ErrorID] [int] NULL,
	[ExecutedDT] [datetime2](7) NULL,
	[DDLHashCheck] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
