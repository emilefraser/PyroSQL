SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[LoadProcedure](
	[ProcedureID] [int] IDENTITY(1,1) NOT NULL,
	[ProcedureName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ProcedureDefinition] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Major] [int] NULL,
	[Minor] [int] NULL,
	[Patch] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
