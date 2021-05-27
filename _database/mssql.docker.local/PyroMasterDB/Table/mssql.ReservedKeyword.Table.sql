SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[mssql].[ReservedKeyword]') AND type in (N'U'))
BEGIN
CREATE TABLE [mssql].[ReservedKeyword](
	[ReservedKeywordId] [smallint] IDENTITY(1,1) NOT NULL,
	[ReservedKeyword] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ReservedKeywordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[mssql].[DF__ReservedK__Creat__768D46E4]') AND type = 'D')
BEGIN
ALTER TABLE [mssql].[ReservedKeyword] ADD  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
