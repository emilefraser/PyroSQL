SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[static].[Dep_type]') AND type in (N'U'))
BEGIN
CREATE TABLE [static].[Dep_type](
	[dep_type_id] [smallint] NOT NULL,
	[dep_type] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dep_type_description] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[record_dt] [datetime] NULL,
	[record_user] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_Dep_type] PRIMARY KEY CLUSTERED 
(
	[dep_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[static].[DF__Dep_type__record__42ADB02B]') AND type = 'D')
BEGIN
ALTER TABLE [static].[Dep_type] ADD  DEFAULT (getdate()) FOR [record_dt]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[static].[DF__Dep_type__record__43A1D464]') AND type = 'D')
BEGIN
ALTER TABLE [static].[Dep_type] ADD  DEFAULT (suser_sname()) FOR [record_user]
END
GO
