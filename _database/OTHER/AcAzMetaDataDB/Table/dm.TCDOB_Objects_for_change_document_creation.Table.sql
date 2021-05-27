SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dm].[TCDOB_Objects_for_change_document_creation]') AND type in (N'U'))
BEGIN
CREATE TABLE [dm].[TCDOB_Objects_for_change_document_creation](
	[OBJECT] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TABNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MULTCASE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOCUDEL] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOCUINS] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[REFNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OLDTABNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ARCHMULT] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOCUD_NOIF] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOCUI_IF] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_TCDOB_Objects_for_change_document_creation] PRIMARY KEY CLUSTERED 
(
	[OBJECT] ASC,
	[TABNAME] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dm].[TCDOB_Objects_for_change_document_creation]') AND name = N'ncix_01')
CREATE NONCLUSTERED INDEX [ncix_01] ON [dm].[TCDOB_Objects_for_change_document_creation]
(
	[TABNAME] ASC
)
INCLUDE([OBJECT],[MULTCASE],[DOCUINS],[DOCUDEL],[REFNAME]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
