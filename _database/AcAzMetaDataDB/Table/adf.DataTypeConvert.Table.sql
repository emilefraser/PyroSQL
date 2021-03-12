SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[DataTypeConvert]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[DataTypeConvert](
	[DataTypeConvertId] [int] IDENTITY(0,1) NOT NULL,
	[SourceTechnologyId] [int] NOT NULL,
	[SourceDataTypeId] [int] NOT NULL,
	[TargetTechnologyId] [int] NOT NULL,
	[TargetDataTypeId] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_DataTypeConvert] PRIMARY KEY CLUSTERED 
(
	[DataTypeConvertId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
