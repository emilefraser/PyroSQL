SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[LoadType](
	[LoadTypeID] [int] IDENTITY(1,1) NOT NULL,
	[LoadTypeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadTypeDescription] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadTypeName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParameterisedTemplateScript] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StaticTemplateScript] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadScriptVersionNo] [decimal](9, 2) NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
