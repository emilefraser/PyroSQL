SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[LoadType]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[LoadType](
	[LoadType] [int] IDENTITY(0,1) NOT NULL,
	[LoadTypeCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoadTypeName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadTypeDescription] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadDefinitionSchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LoadDefinitionProcedureName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_LoadLoadType] PRIMARY KEY CLUSTERED 
(
	[LoadType] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
