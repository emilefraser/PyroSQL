SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[DataEntity](
	[DataEntityID] [int] IDENTITY(1,1) NOT NULL,
	[DataEntityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FriendlyName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataEntityTypeID] [int] NULL,
	[RowsCount] [bigint] NULL,
	[ColumnsCount] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Size] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataQualityScore2] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataQualityScore] [decimal](18, 3) NULL,
	[DESourceCredentialID] [int] NULL,
	[DESourceTypeID] [int] NULL,
	[DEFileFormatID] [int] NULL,
	[SchemaID] [int] NULL,
	[DBObjectID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[LastSeenDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
