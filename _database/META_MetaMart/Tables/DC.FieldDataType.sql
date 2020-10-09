SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[FieldDataType](
	[DataTypeID] [int] IDENTITY(1,1) NOT NULL,
	[DataType] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsConcat] [bit] NULL,
	[SystemTypeID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
