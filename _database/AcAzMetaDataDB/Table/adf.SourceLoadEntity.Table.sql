SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[SourceLoadEntity]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[SourceLoadEntity](
	[SourceLoadEntityID] [int] IDENTITY(1,1) NOT NULL,
	[SourceEntityTechnicalName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_ADF_SourceLoadEntity] PRIMARY KEY CLUSTERED 
(
	[SourceLoadEntityID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
