SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[static].[Server_type]') AND type in (N'U'))
BEGIN
CREATE TABLE [static].[Server_type](
	[server_type_id] [int] NOT NULL,
	[server_type] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[compatibility] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_Server_type] PRIMARY KEY CLUSTERED 
(
	[server_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
