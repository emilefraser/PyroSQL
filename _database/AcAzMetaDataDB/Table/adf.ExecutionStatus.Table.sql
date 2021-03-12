SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[ExecutionStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[ExecutionStatus](
	[ExecutionId] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionStatus] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ExecutionStartDT] [datetime2](7) NOT NULL,
	[ExecutionEndDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
 CONSTRAINT [PK_CurrentRunStatus] PRIMARY KEY CLUSTERED 
(
	[ExecutionId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
