SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[azure].[ArmTemplate]') AND type in (N'U'))
BEGIN
CREATE TABLE [azure].[ArmTemplate](
	[ArmTemplateID] [int] IDENTITY(0,1) NOT NULL,
	[ElementName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ElementRequired] [bit] NOT NULL,
	[ElementDescription] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ElementOrder] [smallint] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_ArmTemplate] PRIMARY KEY CLUSTERED 
(
	[ArmTemplateID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[azure].[DF_ArmTemplate_Required]') AND type = 'D')
BEGIN
ALTER TABLE [azure].[ArmTemplate] ADD  CONSTRAINT [DF_ArmTemplate_Required]  DEFAULT ((1)) FOR [ElementRequired]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[azure].[DF_ArmTemplate_CreatedDT]') AND type = 'D')
BEGIN
ALTER TABLE [azure].[ArmTemplate] ADD  CONSTRAINT [DF_ArmTemplate_CreatedDT]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
