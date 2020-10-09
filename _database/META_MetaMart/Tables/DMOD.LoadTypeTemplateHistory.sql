SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[LoadTypeTemplateHistory](
	[LoadTypeID] [int] NOT NULL,
	[LoadTypeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadTypeName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoadTypeDescription] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParameterisedTemplateScript] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StaticTemplateScript] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadScriptVersionNo] [decimal](9, 2) NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[ModifiedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
	[LoadScriptTemplate] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
