SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[DataType](
	[DataTypeID] [int] IDENTITY(1,1) NOT NULL,
	[DataType] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DataTypeClassification] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsConvertibleToVARCHAR] [bit] NULL,
	[ConversionFunctionToVARHCAR] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsHashable] [bit] NULL,
	[ConversionFunctionToHash] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
