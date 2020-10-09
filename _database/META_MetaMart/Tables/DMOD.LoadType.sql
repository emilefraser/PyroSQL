SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[LoadType](
	[LoadTypeID] [int] IDENTITY(1,1) NOT NULL,
	[LoadTypeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadTypeName] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoadTypeDescription] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParameterisedTemplateScript] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StaticTemplateScript] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadScriptVersionNo] [decimal](9, 2) NULL,
	[DatabasePurposeID] [int] NULL,
	[ETLLoadTypeID] [int] NULL,
	[DataEntityTypeID] [int] NULL,
	[IsStaticTemplateProcessed] [bit] NULL,
	[IsValidated] [bit] NULL,
	[IsExternalTable] [bit] NULL,
	[IsCreatedDTRequired] [bit] NULL,
	[IsUpdatedDTRequired] [bit] NULL,
	[CreatedBy] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ModifiedBy] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[ModifiedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
