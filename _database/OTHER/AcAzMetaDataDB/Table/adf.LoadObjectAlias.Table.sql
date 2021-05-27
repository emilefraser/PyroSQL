SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[LoadObjectAlias]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[LoadObjectAlias](
	[LoadObjectAliasID] [int] IDENTITY(1,1) NOT NULL,
	[ObjectName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ObjectAlias] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ObjectType] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_LoadAliasID] PRIMARY KEY CLUSTERED 
(
	[LoadObjectAliasID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
