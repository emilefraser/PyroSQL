SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[struct].[DataType]') AND type in (N'U'))
BEGIN
CREATE TABLE [struct].[DataType](
	[DataTypeId] [int] IDENTITY(0,1) NOT NULL,
	[TechnologyTypeId] [int] NULL,
	[DataTypeCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataTypeName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataTypeLengthMin] [int] NULL,
	[DataTypeLengthMax] [int] NULL,
	[DataTypePrecisionMin] [smallint] NULL,
	[DataTypePrecisionMax] [smallint] NULL,
	[DataTypeScaleMin] [smallint] NULL,
	[DataTypeScaleMax] [smallint] NULL,
	[MinValue] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MaxValue] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsSigned] [bit] NULL,
	[IsNullable] [bit] NULL,
	[DataTypeFormat] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
 CONSTRAINT [PK_DataType_DataTypeId] PRIMARY KEY CLUSTERED 
(
	[DataTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[struct].[DF_DataType_CreatedDT]') AND type = 'D')
BEGIN
ALTER TABLE [struct].[DataType] ADD  CONSTRAINT [DF_DataType_CreatedDT]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
