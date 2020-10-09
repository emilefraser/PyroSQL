SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [lnd].[TCDOB_Objects_for_change_document_creation](
	[OBJECT] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TABNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MULTCASE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOCUDEL] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOCUINS] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[REFNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OLDTABNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ARCHMULT] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOCUD_NOIF] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DOCUI_IF] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
