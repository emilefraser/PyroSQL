SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[SourceEntity]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[SourceEntity](
	[SourceEntityName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_SourceEntity] PRIMARY KEY CLUSTERED 
(
	[SourceEntityName] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO