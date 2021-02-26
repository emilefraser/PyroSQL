SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[struct].[DataTypeConvertAllow]') AND type in (N'U'))
BEGIN
CREATE TABLE [struct].[DataTypeConvertAllow](
	[DataTypeConvertALlowId] [int] IDENTITY(0,1) NOT NULL,
	[SourceTechnologyId] [int] NULL,
	[SourceDataTypeId] [int] NULL,
	[TargetTechnologyId] [int] NULL,
	[TargetDataTypeId] [int] NULL,
	[IsImplicitConvertAllowed] [bit] NULL,
	[IsExplicitConvertAllowed] [bit] NULL,
	[CreatedDT] [datetime2](7) NULL,
 CONSTRAINT [PK__DataType__360737951E3F538D] PRIMARY KEY CLUSTERED 
(
	[DataTypeConvertALlowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[struct].[DF__DataTypeConvert_CreatedDT]') AND type = 'D')
BEGIN
ALTER TABLE [struct].[DataTypeConvertAllow] ADD  CONSTRAINT [DF__DataTypeConvert_CreatedDT]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
