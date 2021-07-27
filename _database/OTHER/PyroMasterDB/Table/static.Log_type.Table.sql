SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[static].[Log_type]') AND type in (N'U'))
BEGIN
CREATE TABLE [static].[Log_type](
	[log_type_id] [smallint] NOT NULL,
	[log_type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[min_log_level_id] [int] NULL,
 CONSTRAINT [PK_Log_type_1] PRIMARY KEY CLUSTERED 
(
	[log_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO