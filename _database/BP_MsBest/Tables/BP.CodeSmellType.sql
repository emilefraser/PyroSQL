SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [BP].[CodeSmellType](
	[SmellTypeID] [int] IDENTITY(1,1) NOT NULL,
	[SmellTypeCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SmellTypeDecription] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SmellSchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime] NOT NULL,
	[UpdatedDT] [datetime] NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO
