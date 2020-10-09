SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [INTEGRATION].[ingress_DataCatalog_MySQL](
	[DCDatabaseInstanceID] [bigint] NULL,
	[DatabaseID] [bigint] NULL,
	[DatabaseName] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemaID] [varbinary](max) NULL,
	[SchemaName] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataEntityID] [varbinary](max) NULL,
	[DataEntityName] [nvarchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ColumnID] [int] NULL,
	[ColumnName] [nvarchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataType] [nvarchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MaxLength] [bigint] NULL,
	[Precision] [decimal](20, 0) NULL,
	[Scale] [decimal](20, 0) NULL,
	[IsPrimaryKey] [bigint] NULL,
	[IsForeignKey] [varbinary](max) NULL,
	[DefaultValue] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsSystemGenerated] [varbinary](max) NULL,
	[RowCount] [decimal](20, 0) NULL,
	[DataEntitySize] [decimal](25, 2) NULL,
	[DatabaseSize] [varbinary](max) NULL,
	[IsActive] [bigint] NULL,
	[FieldSortOrder] [decimal](20, 0) NULL,
	[DataEntityTypeCode] [nvarchar](7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
