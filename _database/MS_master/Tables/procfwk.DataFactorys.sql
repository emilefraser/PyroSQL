SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [procfwk].[DataFactorys](
	[DataFactoryId] [int] IDENTITY(1,1) NOT NULL,
	[DataFactoryName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ResourceGroupName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
