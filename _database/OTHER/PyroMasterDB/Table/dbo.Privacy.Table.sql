SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Privacy]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Privacy](
	[db] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[table_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sensitive] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[column_name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[personal] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
