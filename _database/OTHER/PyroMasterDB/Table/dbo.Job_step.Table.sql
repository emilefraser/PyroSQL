SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Job_step]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Job_step](
	[job_step_id] [int] IDENTITY(1,1) NOT NULL,
	[step_id] [int] NULL,
	[step_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[subsystem] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[command] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[on_success_action] [int] NULL,
	[on_success_step_id] [int] NULL,
	[on_fail_action] [int] NULL,
	[on_fail_step_id] [int] NULL,
	[database_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[job_id] [int] NULL,
 CONSTRAINT [PK_job_step] PRIMARY KEY CLUSTERED 
(
	[job_step_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Job_step__step_i__336B6C9B]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Job_step] ADD  DEFAULT ((1)) FOR [step_id]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Job_step__subsys__345F90D4]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Job_step] ADD  DEFAULT ('SSIS') FOR [subsystem]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Job_step__on_suc__3553B50D]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Job_step] ADD  DEFAULT ((3)) FOR [on_success_action]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Job_step__on_suc__3647D946]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Job_step] ADD  DEFAULT ((0)) FOR [on_success_step_id]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Job_step__on_fai__373BFD7F]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Job_step] ADD  DEFAULT ((2)) FOR [on_fail_action]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Job_step__databa__383021B8]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Job_step] ADD  DEFAULT ('master') FOR [database_name]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Job_step_Job]') AND parent_object_id = OBJECT_ID(N'[dbo].[Job_step]'))
ALTER TABLE [dbo].[Job_step]  WITH CHECK ADD  CONSTRAINT [FK_Job_step_Job] FOREIGN KEY([job_id])
REFERENCES [dbo].[Job] ([job_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Job_step_Job]') AND parent_object_id = OBJECT_ID(N'[dbo].[Job_step]'))
ALTER TABLE [dbo].[Job_step] CHECK CONSTRAINT [FK_Job_step_Job]
GO
