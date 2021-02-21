SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[azure].[ArmSchema]') AND type in (N'U'))
BEGIN
CREATE TABLE [azure].[ArmSchema](
	[ElementId] [int] NOT NULL,
	[ElementCode] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ElementName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ElementDataTypeId] [int] NOT NULL,
	[IsElementRequired] [bit] NOT NULL,
	[ElementDescription] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ElementId_Parent] [int] NULL,
	[ElementLevel] [smallint] NOT NULL,
	[ElementOrder] [smallint] NULL,
	[ElementDefinition] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
 CONSTRAINT [PK_ArmSchema_ElementId] PRIMARY KEY CLUSTERED 
(
	[ElementId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[azure].[DF__ArmSchema__IsEle__55009F39]') AND type = 'D')
BEGIN
ALTER TABLE [azure].[ArmSchema] ADD  DEFAULT ((0)) FOR [IsElementRequired]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[azure].[DF_ArmSchema_CreatedDT]') AND type = 'D')
BEGIN
ALTER TABLE [azure].[ArmSchema] ADD  CONSTRAINT [DF_ArmSchema_CreatedDT]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[azure].[FK_ArmSchema_ArmDataType]') AND parent_object_id = OBJECT_ID(N'[azure].[ArmSchema]'))
ALTER TABLE [azure].[ArmSchema]  WITH CHECK ADD  CONSTRAINT [FK_ArmSchema_ArmDataType] FOREIGN KEY([ElementDataTypeId])
REFERENCES [azure].[ArmDataType] ([ArmDataTypeId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[azure].[FK_ArmSchema_ArmDataType]') AND parent_object_id = OBJECT_ID(N'[azure].[ArmSchema]'))
ALTER TABLE [azure].[ArmSchema] CHECK CONSTRAINT [FK_ArmSchema_ArmDataType]
GO
