SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[MetaInformation]') AND type in (N'U'))
BEGIN
CREATE TABLE [dss].[MetaInformation](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[VersionMajor] [int] NOT NULL,
	[VersionMinor] [int] NOT NULL,
	[VersionBuild] [int] NOT NULL,
	[VersionService] [int] NOT NULL,
	[VersionString] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Version] [bigint] NULL,
	[State] [bit] NOT NULL,
	[Timestamp] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__MetaInfor__Versi__255C790F]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[MetaInformation] ADD  DEFAULT ((0)) FOR [VersionService]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__MetaInfor__Versi__2838E5BA]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[MetaInformation] ADD  DEFAULT ('1.0.0.0') FOR [VersionString]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__MetaInfor__State__26509D48]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[MetaInformation] ADD  DEFAULT ((1)) FOR [State]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__MetaInfor__Times__2744C181]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[MetaInformation] ADD  DEFAULT (getutcdate()) FOR [Timestamp]
END
GO
