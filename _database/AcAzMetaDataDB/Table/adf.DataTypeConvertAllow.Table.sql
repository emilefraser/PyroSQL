SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[DataTypeConvertAllow]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[DataTypeConvertAllow](
	[DataTypeConvertALlowID] [int] IDENTITY(0,1) NOT NULL,
	[SourceTechnologyID] [int] NULL,
	[SourceDataTypeID] [int] NULL,
	[TargetTechnologyID] [int] NULL,
	[TargetDataTypeID] [int] NULL,
	[IsImplicitConvertAllowed] [bit] NULL,
	[IsExplicitConvertAllowed] [bit] NULL,
	[CreatedDT] [datetime2](7) NULL,
 CONSTRAINT [PK__DataType__360737951E3F538D] PRIMARY KEY CLUSTERED 
(
	[DataTypeConvertALlowID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
