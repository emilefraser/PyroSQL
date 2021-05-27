SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[static].[Column_type]') AND type in (N'U'))
BEGIN
CREATE TABLE [static].[Column_type](
	[column_type_id] [int] NOT NULL,
	[column_type_name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[column_type_description] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[record_dt] [datetime] NULL,
	[record_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_Column_type] PRIMARY KEY CLUSTERED 
(
	[column_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
