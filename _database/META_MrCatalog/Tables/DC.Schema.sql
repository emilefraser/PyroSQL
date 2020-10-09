SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[Schema](
	[SchemaID] [int] IDENTITY(1,1) NOT NULL,
	[SchemaName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DatabaseID] [int] NOT NULL,
	[DBSchemaID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[LastSeenDT] [datetime2](7) NULL,
	[SystemID] [int] NULL
) ON [PRIMARY]

GO
