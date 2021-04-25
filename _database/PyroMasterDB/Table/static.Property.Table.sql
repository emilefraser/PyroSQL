SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[static].[Property]') AND type in (N'U'))
BEGIN
CREATE TABLE [static].[Property](
	[property_id] [int] NOT NULL,
	[property_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[description] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[property_scope] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[default_value] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[apply_table] [bit] NULL,
	[apply_view] [bit] NULL,
	[apply_schema] [bit] NULL,
	[apply_db] [bit] NULL,
	[apply_srv] [bit] NULL,
	[apply_user] [bit] NULL,
	[record_dt] [datetime] NULL,
	[record_user] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_Property_1] PRIMARY KEY CLUSTERED 
(
	[property_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[static].[DF__Property__record__4495F89D]') AND type = 'D')
BEGIN
ALTER TABLE [static].[Property] ADD  DEFAULT (getdate()) FOR [record_dt]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[static].[DF__Property__record__458A1CD6]') AND type = 'D')
BEGIN
ALTER TABLE [static].[Property] ADD  DEFAULT (suser_sname()) FOR [record_user]
END
GO
