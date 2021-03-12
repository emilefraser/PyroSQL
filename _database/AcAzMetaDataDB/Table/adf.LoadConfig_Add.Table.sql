SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[LoadConfig_Add]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[LoadConfig_Add](
	[LoadConfigAdd_ID] [int] IDENTITY(1,1) NOT NULL,
	[SapTableName] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SapTableEnvironment] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
