SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [lnd].[CDPOS_Change_document_items](
	[MANDANT] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OBJECTCLAS] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OBJECTID] [nvarchar](90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CHANGENR] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TABNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TABKEY] [nvarchar](70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FNAME] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CHNGIND] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TEXT_CASE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UNIT_OLD] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UNIT_NEW] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CUKY_OLD] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CUKY_NEW] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VALUE_NEW] [nvarchar](254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VALUE_OLD] [nvarchar](254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[_DATAAGING] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
