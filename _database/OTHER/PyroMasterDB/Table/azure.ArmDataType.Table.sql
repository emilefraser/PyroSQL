SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[azure].[ArmDataType]') AND type in (N'U'))
BEGIN
CREATE TABLE [azure].[ArmDataType](
	[ArmDataTypeId] [int] NOT NULL,
	[DataTypeName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DataTypeDescription] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DefaultValue] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PatternIndex] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SqlServerDataType] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SqlServerConversionDefinition] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_ArmDataType] PRIMARY KEY CLUSTERED 
(
	[ArmDataTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[azure].[DF_ArmDataType_CreatedDT]') AND type = 'D')
BEGIN
ALTER TABLE [azure].[ArmDataType] ADD  CONSTRAINT [DF_ArmDataType_CreatedDT]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
