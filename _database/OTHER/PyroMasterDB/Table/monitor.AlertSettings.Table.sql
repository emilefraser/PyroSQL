SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[monitor].[AlertSettings]') AND type in (N'U'))
BEGIN
CREATE TABLE [monitor].[AlertSettings](
	[AlertName] [nvarchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VariableName] [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Enabled] [bit] NULL,
	[Value] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[monitor].[df_AlertSettings_Enabled]') AND type = 'D')
BEGIN
ALTER TABLE [monitor].[AlertSettings] ADD  CONSTRAINT [df_AlertSettings_Enabled]  DEFAULT ((1)) FOR [Enabled]
END
GO
