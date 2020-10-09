SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [INTEGRATION].[ingress_DataCatalog](
	[DCDatabaseInstanceID] [int] NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemaID] [int] NULL,
	[SchemaName] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataEntityID] [int] NULL,
	[DataEntityName] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ColumnID] [int] NULL,
	[ColumnName] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataType] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MaxLength] [int] NULL,
	[Precision] [int] NULL,
	[Scale] [int] NULL,
	[IsPrimaryKey] [int] NULL,
	[IsForeignKey] [int] NULL,
	[DefaultValue] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsSystemGenerated] [int] NULL,
	[RowCount] [int] NULL,
	[DataEntitySize] [decimal](18, 3) NULL,
	[DatabaseSize] [decimal](18, 3) NULL,
	[IsActive] [bit] NULL,
	[FieldSortOrder] [int] NULL,
	[DataEntityTypeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
