SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[static].[Log_level]') AND type in (N'U'))
BEGIN
CREATE TABLE [static].[Log_level](
	[log_level_id] [smallint] NOT NULL,
	[log_level] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[log_level_description] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_Log_level_1] PRIMARY KEY CLUSTERED 
(
	[log_level_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
