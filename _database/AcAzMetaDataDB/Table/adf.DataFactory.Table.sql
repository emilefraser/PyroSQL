SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[DataFactory]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[DataFactory](
	[DataFactoryId] [int] IDENTITY(0,1) NOT NULL,
	[DataFactoryResourceID] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataFactoryName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataFactoryVersion] [smallint] NULL,
	[ResourceGroupName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SubscriptionGUID] [uniqueidentifier] NULL,
	[SubscriptionName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AzureActiveDirectoryGUID] [uniqueidentifier] NULL,
	[AzureActiveDirectoryName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_DataFactoryID] PRIMARY KEY CLUSTERED 
(
	[DataFactoryId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
