SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DataModelDataSource](
	[DSID] [bigint] IDENTITY(1,1) NOT NULL,
	[ItemId] [uniqueidentifier] NOT NULL,
	[DSType] [varchar](100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DSKind] [varchar](100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AuthType] [varchar](100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ConnectionString] [varbinary](max) NULL,
	[Username] [varbinary](max) NULL,
	[Password] [varbinary](max) NULL,
	[ModelConnectionName] [varchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedByID] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedByID] [uniqueidentifier] NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[DataSourceID] [uniqueidentifier] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
