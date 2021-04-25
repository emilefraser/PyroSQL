SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Stack]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Stack](
	[stack_id] [int] IDENTITY(1,1) NOT NULL,
	[value] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[record_dt] [datetime] NULL,
	[record_user] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_Stack] PRIMARY KEY CLUSTERED 
(
	[stack_id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Stack__record_dt__3FD14380]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Stack] ADD  DEFAULT (getdate()) FOR [record_dt]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Stack__record_us__40C567B9]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Stack] ADD  DEFAULT (suser_sname()) FOR [record_user]
END
GO
