SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Error]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Error](
	[error_id] [int] IDENTITY(1,1) NOT NULL,
	[error_code] [int] NULL,
	[error_msg] [varchar](5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[error_line] [int] NULL,
	[error_procedure] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[error_procedure_id] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[error_execution_id] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[error_event_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[error_severity] [int] NULL,
	[error_state] [int] NULL,
	[error_source] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[error_interactive_mode] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[error_machine_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[error_user_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[transfer_id] [int] NULL,
	[record_dt] [datetime] NULL,
	[record_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_error_id] PRIMARY KEY CLUSTERED 
(
	[error_id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Error__record_dt__31832429]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Error] ADD  DEFAULT (getdate()) FOR [record_dt]
END
GO
