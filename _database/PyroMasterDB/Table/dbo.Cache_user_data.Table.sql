SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cache_user_data]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Cache_user_data](
	[user_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[log_level] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[exec_sql] [bit] NULL,
	[record_dt] [datetime] NULL,
	[expiration_dt] [datetime] NULL,
 CONSTRAINT [PK_Cache_1] PRIMARY KEY CLUSTERED 
(
	[user_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Cache_use__recor__2DB29345]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Cache_user_data] ADD  DEFAULT (getdate()) FOR [record_dt]
END
GO
