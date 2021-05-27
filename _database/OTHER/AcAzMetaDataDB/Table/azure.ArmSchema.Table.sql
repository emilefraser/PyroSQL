SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[azure].[ArmSchema]') AND type in (N'U'))
BEGIN
CREATE TABLE [azure].[ArmSchema](
	[ArmSchemaID] [int] IDENTITY(0,1) NOT NULL,
	[ArmSchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ArmSchemaDescription] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ArmSchemaSpecificationUri] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ArmSchemaUri] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ArmSchemaStorageAccount] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ArmSchemaContainer] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ArmSchemaPath] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ArmSchemaDefinition] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
 CONSTRAINT [PK__ArmSchem__85212A0C94F84CE1] PRIMARY KEY CLUSTERED 
(
	[ArmSchemaID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[azure].[DF__ArmSchema__Creat__286DEFE4]') AND type = 'D')
BEGIN
ALTER TABLE [azure].[ArmSchema] ADD  CONSTRAINT [DF__ArmSchema__Creat__286DEFE4]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
