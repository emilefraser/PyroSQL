SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[DataType]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[DataType](
	[DataTypeId] [int] IDENTITY(0,1) NOT NULL,
	[TechnologyTypeId] [int] NULL,
	[DataTypeCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataTypeName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataTypeMaxLength] [int] NULL,
	[DataTypePrecision] [smallint] NULL,
	[DataTypeScale] [smallint] NULL,
	[DataTypeIsNullable] [bit] NULL,
	[DataTypeFormat] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
 CONSTRAINT [PK__DataType__4382083FC1C437ED] PRIMARY KEY CLUSTERED 
(
	[DataTypeId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
