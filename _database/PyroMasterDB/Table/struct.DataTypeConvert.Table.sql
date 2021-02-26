SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[struct].[DataTypeConvert]') AND type in (N'U'))
BEGIN
CREATE TABLE [struct].[DataTypeConvert](
	[DataTypeConvertId] [int] IDENTITY(0,1) NOT NULL,
	[SourceTechnologyId] [int] NOT NULL,
	[SourceDataTypeId] [int] NOT NULL,
	[TargetTechnologyId] [int] NOT NULL,
	[TargetDataTypeId] [int] NOT NULL,
	[TargetDataTypeLengthOverride] [int] NULL,
	[TargetDataTypeScaleOverride] [int] NULL,
	[TargetDataTypePrecisionOverride] [int] NULL,
	[TargetDataTypeIsNullableOverride] [bit] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_DataTypeConvert] PRIMARY KEY CLUSTERED 
(
	[DataTypeConvertId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[struct].[DF_TypeConvert_CreatedDT]') AND type = 'D')
BEGIN
ALTER TABLE [struct].[DataTypeConvert] ADD  CONSTRAINT [DF_TypeConvert_CreatedDT]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
