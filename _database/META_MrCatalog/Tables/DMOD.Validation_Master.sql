SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[Validation_Master](
	[ValidationID] [int] IDENTITY(1,1) NOT NULL,
	[ValidationName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ValidationDescription] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Database_Validated] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Valiation_Category] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ValiationObject_Type] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ObjectName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO
