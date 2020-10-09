SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [INTEGRATION].[ingress_DataCatalog](
	[DCDatabaseInstanceID] [int] NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemaID] [int] NULL,
	[SchemaName] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataEntityID] [int] NULL,
	[DataEntityName] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ColumnID] [int] NULL,
	[ColumnName] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataType] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MaxLength] [smallint] NULL,
	[Precision] [smallint] NULL,
	[Scale] [tinyint] NULL,
	[IsPrimaryKey] [int] NULL,
	[IsForeignKey] [int] NULL,
	[DefaultValue] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsSystemGenerated] [int] NULL,
	[RowCount] [int] NULL,
	[DataEntitySize] [decimal](18, 3) NULL,
	[DatabaseSize] [decimal](18, 3) NULL,
	[IsActive] [bit] NULL,
	[FieldSortOrder] [int] NULL,
	[DataEntityTypeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
