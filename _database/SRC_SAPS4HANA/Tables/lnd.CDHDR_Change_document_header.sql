SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [lnd].[CDHDR_Change_document_header](
	[MANDANT] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OBJECTCLAS] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OBJECTID] [nvarchar](90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CHANGENR] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[USERNAME] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UDATE] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UTIME] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TCODE] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PLANCHNGNR] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ACT_CHNGNO] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[WAS_PLANND] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CHANGE_IND] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LANGU] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VERSION] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[_DATAAGING] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
