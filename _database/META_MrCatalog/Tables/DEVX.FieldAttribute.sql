SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DEVX].[FieldAttribute](
	[FieldAttributeID] [int] IDENTITY(1,1) NOT NULL,
	[FieldID] [int] NOT NULL,
	[FieldName] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsCreateScalarFunction] [bit] NOT NULL,
	[IsCreateTableValuedFunction] [bit] NOT NULL,
	[CreatedDT]  AS (CONVERT([datetime2](7),getdate())),
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO
