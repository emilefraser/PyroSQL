SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[agent_version]') AND type in (N'U'))
BEGIN
CREATE TABLE [dss].[agent_version](
	[Id] [int] NOT NULL,
	[Version] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ExpiresOn] [datetime] NOT NULL,
	[Comment] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Version] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__agent_ver__Expir__292D09F3]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[agent_version] ADD  DEFAULT ('9999-12-31 23:59:59.997') FOR [ExpiresOn]
END
GO
