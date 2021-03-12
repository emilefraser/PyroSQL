SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[EnumType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dss].[EnumType](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Type] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EnumId] [int] NOT NULL,
	[LastModified] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__EnumType__LastMo__218BE82B]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[EnumType] ADD  DEFAULT (getutcdate()) FOR [LastModified]
END
GO
